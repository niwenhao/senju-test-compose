module Senju::TestCase::RunnerHelper
  class TestContext
    attr_accessor :host, :user

    def initialize(host, user)
      @host = host
      @user = user
    end
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

      return TestContext.new(host: config.default.exec_env.host, user: config.default.exec_env.user)
    end
  end

  class TestCaseExecuter
    include Senju::TestCase::RunnerHelper::TaskExecuterHelper

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

    def execute_senju_job(ctx, senjuJob)
      task = {
        env: {
          host: ctx.host,
          user: ctx.user
        },
        exec: {
          type: "",
          script: senjuJob.command
        }
      }

      execute_task task
    end

    def execute_references(hctx, refs)
      while refs.size > 0
        r = refs.shift
        refctx = r.find_exec_env(@config, nil)
        objctx = r.senjuObject.find_exec_env(@config, nil)

        ctx = hctx
        ctx = objctx if objctx
        ctx = refctx if objctx


        r.left.each do |prev|
          task = config.tasks.by_succession[r.senjuNet.name][pref.senjuObject.name][r.senjuObject.name]
          if task.nil? then
            ret = execute_task task
            if ret == TaskExecuter::STATUS_OK.code then
              raise TaskExecuter::STATUS_OK
            end
            if ret == TaskExecuter::STATUS_NG.code then
              raise TaskExecuter::STATUS_NG
            end
          end
        end

        ret = TaskExecuter::STATUS_CONT.code

        task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].pre_task
        unless task.nil? then
          ret = execute_task task
          if ret == TaskExecuter::STATUS_OK.code then
            raise TaskExecuter::STATUS_OK
          end
          if ret == TaskExecuter::STATUS_NG.code then
            raise TaskExecuter::STATUS_NG
          end
        end

        if ret == TaskExecuter::STATUS_CONT.code then
          ret = TaskExecuter::STATUS_CONT.code
          task = config.tasks.by_name[r.senjuObject.name].pre_task
          unless task.nil? then
            ret = execute_task task
            if ret == TaskExecuter::STATUS_OK.code then
              raise TaskExecuter::STATUS_OK
            end
            if ret == TaskExecuter::STATUS_NG.code then
              raise TaskExecuter::STATUS_NG
            end
          end

          if ret == TaskExecuter::STATUS_CONT.code
            if r.senjuObject.instanceof? SenjuNet then
              newrefs = []
              r.senjuObject.netReferences.each do |nr|
                newrefs << nr if nr.leftLink.size == 0
              end

              execute_references(ctx, newrefs)
            elsif r.senjuObject.instanceof? SenjuJob then
              ret = execute_senju_job(ctx, r.senjuObject)
              $ENV[TaskExecuter::SENJU_STATUS] = ret
              $ENV[TaskExecuter::SENJU_EXPECTED] = r.senjuObject.expected
            end
          end

          r.right.each do |n|
            refs << n
          end

          task = config.tasks.by_name[r.senjuObject.name].post_task
          unless task.nil? then
            ret = execute_task task
            if ret == TaskExecuter::STATUS_OK.code then
              raise TaskExecuter::STATUS_OK
            end
            if ret == TaskExecuter::STATUS_NG.code then
              raise TaskExecuter::STATUS_NG
            end
          end
        end

        task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].post_task
        unless task.nil? then
          ret = execute_task task
          if ret == TaskExecuter::STATUS_OK.code then
            raise TaskExecuter::STATUS_OK
          end
          if ret == TaskExecuter::STATUS_NG.code then
            raise TaskExecuter::STATUS_NG
          end
        end
      end
    end

  end
end
