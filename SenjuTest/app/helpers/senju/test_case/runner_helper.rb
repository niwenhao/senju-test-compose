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
      unless c.nil? then
        return TestContext.new(c.host, c.user)
      end

      c = config.exec_envs.by_name[self.senjuEnv.name] if self.senjuEnv
      unless c.nil? then
        return TestContext.new(c.host, c.user)
      end

      return hctx if hctx
    end
  end

  class TestCaseExecuter
    include Senju::CommonLogHelper
    include Senju::TestCase::RunnerHelper::TaskExecuterHelper::TaskExecuter
    include Senju::CommonHelper

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def start
      
      debug { "PreTask of the test case will begin\n #{@config.pre_task}" }

      execute_task @config.pre_task unless @config.pre_task.nil?

      info { "Top net is #{@config.net_name}" }
      init_test SenjuNet.find_by name: @config.net_name

      debug { "PostTask of the test case will begin\n #{@config.post_task}" }
      execute_task @config.post_task unless @config.post_task.nil?
    end

    def init_test(net)
      ctx = net.find_exec_env(@config, TestContext.new(@config.default.exec_env.host, @config.default.exec_env.user))
      debug { "ネット<#{net.name}>の環境を取得しました。=> #{ctx}" }


      unless @config.tasks[net.name].pre_task.nil? then
        info { "ネットの事前タスクを実行する。\n#{@config.tasks[net.name].pre_task}" }
        execute_task @config.tasks[net.name].pre_task
      end


      execute_net_objects ctx, net

      unless @config.tasks[net.name].post_task then
        execute_task @config.tasks[net.name].post_task
      end
    end

    def execute_net_objects(ctx, net)
      info { 
        <<EOS
ネット配下オブジェクトを実行する。
ネット  ：#{net.name}
説明    ：#{net.description}
EOS
      }
      waits = []
      finished = []
      ready = []

      debug { "ネットの全オブジェクトを実行待ちバッファに入れる。" }
      net.refs.each do |r|
        waits << r
      end

      until waits.empty? do
        debug { "実行できるオブジェクトを選出する。" }
        ready = waits.select do |r|
          flg = r.left.empty?
          unless flg
            flg = true
            r.left.each do |l|
              flg = flg && finished.include?(l)
            end
          end
          flg
        end

        debug { ready.inspect }

        ready.each do |r|
          debug { "オブジェクト（#{r.senjuNet.name}:#{r.senjuObject.name}）を実行し、実行待ちから実行完了に移動する。" }
          execute_reference ctx, r
          finished << r
          waits.delete r
        end
      end

    end

    def execute_reference(hctx, r)
      info { <<EOS
ネットオブジェクトを実行する
ネット        ：#{r.senjuNet.name}
オブジェクト  ：#{r.senjuObject.class::SENJU_TYPE}/#{r.senjuObject.name}
EOS
      }
      refctx = r.find_exec_env(@config, nil)
      objctx = r.senjuObject.find_exec_env(@config, nil)

      ctx = hctx
      ctx = objctx if objctx
      ctx = refctx if refctx

      ENV[SENJU_STATUS] = "0"
      ENV[SENJU_EXPECTED] = "0"

      info { <<EOS
稼動環境確定
ホスト  ：#{ctx.host}
ユーザ  ：#{ctx.user}
EOS
      }
      r.left.each do |prev|
        task = config.tasks.by_succession[r.senjuNet.name][prev.senjuObject.name][r.senjuObject.name]
        unless task.nil? then
          info { <<EOS
後続関係の定義タスクを実行する。
先行        ：#{prev.senjuObject.class::SENJU_TYPE}/#{prev.senjuObject.name}
後続        ：#{r.senjuObject.class::SENJU_TYPE}/#{r.senjuObject.name}
EOS
          }
          ret = execute_task task
          if ret == STATUS_OK.code then
            raise STATUS_OK
          end
          if ret == STATUS_NG.code then
            raise STATUS_NG
          end
          if ret == STATUS_BYEBUG.code then
            byebug
            ret = STATUS_CONT.code
          end
        end
      end

      ret = STATUS_CONT.code

      task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].pre_task
      task = config.default.pre_task if task.nil?
      info { "ネットのオブジェクト（#{r.senjuNet.name}:#{r.senjuObject.name}）の先行タスクを実行する" }
      ret = execute_task task
      if ret == STATUS_OK.code then
        raise STATUS_OK
      end
      if ret == STATUS_NG.code then
        raise STATUS_NG
      end
      if ret == STATUS_BYEBUG.code then
        byebug
        ret = STATUS_CONT.code
      end

      if ret == STATUS_CONT.code then
        ret = STATUS_CONT.code
        task = config.tasks.by_name[r.senjuObject.name].pre_task
        task = config.default.pre_task if task.nil?
        info { "オブジェクト（#{r.senjuObject.name}）の先行タスクを実行する" }
        ret = execute_task task
        if ret == STATUS_OK.code then
          raise STATUS_OK
        end
        if ret == STATUS_NG.code then
          raise STATUS_NG
        end
        if ret == STATUS_BYEBUG.code then
          byebug
          ret = STATUS_CONT.code
        end

        if ret == STATUS_CONT.code
          if r.senjuObject.is_a? SenjuNet then
            execute_net_objects(ctx, r.senjuObject)
          elsif r.senjuObject.is_a? SenjuJob then
            execute_senju_job(config, ctx, r.senjuObject)
          end
        end

        task = config.tasks.by_name[r.senjuObject.name].post_task
        task = config.default.post_task if task.nil?
        info { "オブジェクト（#{r.senjuObject.name}）の後続タスクを実行する" }
        ret = execute_task task
        if ret == STATUS_OK.code then
          raise STATUS_OK
        end
        if ret == STATUS_NG.code then
          raise STATUS_NG
        end
        if ret == STATUS_BYEBUG.code then
          byebug
          ret = STATUS_CONT.code
        end
      end

      task = config.tasks.by_reference[r.senjuNet.name][r.senjuObject.name].post_task
      task = config.default.post_task if task.nil?
      info { "ネットのオブジェクト（#{r.senjuNet.name}:#{r.senjuObject.name}）の後続タスクを実行する" }
      ret = execute_task task
      if ret == STATUS_OK.code then
        raise STATUS_OK
      end
      if ret == STATUS_NG.code then
        raise STATUS_NG
      end
      if ret == STATUS_BYEBUG.code then
        byebug
        ret = STATUS_CONT.code
      end
    end

    def execute_senju_job(config, ctx, senjuJob)

      env = Hash.new
      ENV["SJ_PEX_DATE"] = config.senju_date
      ENV["SJ_PEX_JOB"] = senjuJob.name

      info { <<EOS
千手ジョブを実行する。
稼動環境
  ホスト    ：#{ctx.host}
  ユーザ    ：#{ctx.user}
千手日付    ：#{config.senju_date}
千手ジョブ  ：#{senjuJob.name}
コマンド    ：#{senjuJob.command}
説明        ：#{senjuJob.description}
EOS
           }

      info { "ssh -o 'SendEnv SJ_*' #{ctx.user}@#{ctx.host} '#{senjuJob.command}'" }
      system "ssh -o 'SendEnv SJ_*' #{ctx.user}@#{ctx.host} '#{senjuJob.command}'"

      info { <<EOS
千手ジョブが実行完了
実行結果    ：#{$?.exitstatus}
期待コード  ：#{senjuJob.expected}
EOS
           }

      ENV[SENJU_STATUS] = $?.exitstatus.to_s
      ENV[SENJU_EXPECTED] = senjuJob.expected.to_s

      $?.exitstatus.to_s
    end

  end
end
