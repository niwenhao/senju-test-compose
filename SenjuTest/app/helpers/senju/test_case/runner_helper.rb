module Senju::TestCase::RunnerHelper
  class TestContext
    attr_accessor :host, :user
  end

  module ExecEnvDigger
    def find_exec_env(config, hctx)
      c = config.exec_envs.by_name[self.name]
      if c then
        return TestContext.new(host: c.host, user: c.user)
      end

      return hctx if hctx

      c = config.exec_envs.by_name[self.senjuEnv.name] if self.senjuEnv
      if c then
        return TestContext.new(host: c.host, user: c.user)
      end

      return TestContext.new(host: config.default.exec_env.host, user: config.default.exec_env.host)
    end
  end

  class TestCaseExecuter
    attr_accessor :config, :test_net

    def start
      execute_task @config.pre_task

      init_test @test_net

      execute_task @config.post_task
    end

    def init_test(net)
      ctx = net.find_exec_env(@config, nil)

      unless @config.tasks[net.name].pre_task.nil? then
        execute_task @config.tasks[net.name].pre_task
      end


      starts = []
      net.netReferences.each do |ref|
        starts << ref if ref.leftLink.size == 0
      end

      execute_object ctx, starts

      unless @config.tasks[net.name].post_task then
        execute_task @config.tasks[net.name].post_task
      end
    end

    def execute_references(hctx, refs)
      while refs.size > 0
        r = refs.shift
        refctx = r.find_exec_env(@config, nil)
        objctx = r.senjuObject.find_exec_env(@config, nil)

        ctx = hctx
        ctx = objctx if objctx
        ctx = refctx if objctx

        task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].pre_task
        unless task.nil? then
          execute_task task
        end

        task = config.tasks.by_name[r.senjuObject.name].pre_task
        unless task.nil? then
          execute_task task
        end

        if r.senjuObject.instanceof? SenjuNet then
          newrefs = []
          r.senjuObject.netReferences.each do |nr|
            newrefs << nr if nr.leftLink.size == 0
          end

          execute_references(ctx, newrefs)
        elsif r.senjuObject.instanceof? SenjuJob then
          execute_senju_job(ctx, r.senjuObject)
        end

        r.right.each do |r|
          refs << r
        end

        task = config.tasks.by_name[r.senjuObject.name].post_task
        unless task.nil? then
          execute_task task
        end

        task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].post_task
        unless task.nil? then
          execute_task task
        end
      end
    end

  end
end
