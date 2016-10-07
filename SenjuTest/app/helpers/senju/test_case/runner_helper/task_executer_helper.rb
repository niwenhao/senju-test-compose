require 'open3'

module Senju::TestCase::RunnerHelper::TaskExecuterHelper
  module TaskExecuter
    include Senju::CommonLogHelper

    #
    # タスクの実行結果を連携するクラス
    #
    class TestExitException < Exception
      attr_accessor :code

      def initialize(code)
        @code = code
      end
    end

    # タスクの戻り値、OK/NGでテスト終了したい場合、raise対象になる。
    STATUS_OK = TestExitException.new 91
    STATUS_NG = TestExitException.new 92
    STATUS_CONT = TestExitException.new 0
    STATUS_SKIP = TestExitException.new 93
    STATUS_BYEBUG = TestExitException.new 94
    # ジョブを実行する場合、戻り値とジョブの期待値を環境変数にいれって、次のタスクに渡す。
    SENJU_STATUS = "SJ_EXIT_STATUS"
    SENJU_EXPECTED = "SJ_EXIT_EXPECTED"

    ENV["SJ_RET_OK"] = STATUS_OK.code.to_s
    ENV["SJ_RET_NG"] = STATUS_NG.code.to_s
    ENV["SJ_RET_CONT"] = STATUS_CONT.code.to_s
    ENV["SJ_RET_SKIP"] = STATUS_SKIP.code.to_s
    ENV["SJ_RET_BYEBUG"] = STATUS_BYEBUG.code.to_s

    #
    # タスクを実行する
    # task : 実行タスク定義
    #         task:
    #           env:
    #             host: xxx
    #             user: yyy
    #           exec:
    #             type: csh
    #             script: |
    #               aaaa
    #               bbbb
    #               cccc
    #
    def execute_task(task)
      info { <<EOS
タスクを実行する。
ホスト      ：#{task.env.host}
ユーザ      ：#{task.env.user}
タイプ      ：#{task.exec.type}
スクリプト  ：#{task.exec.script}
EOS
            }

      cmd = ""

      if task.env.nil? then
        cmd = task.exec.type
      else
        cmd = "ssh -o \"SendEnv=SJ_*\" #{task.env.user}@#{task.env.host} \"#{task.exec.type}\""
      end

      IO.popen(ENV, cmd, "w") do |io|
        io << task.exec.script
      end

      info { <<EOS
タスクが実行完了。
EXIT CODE  ：#{$?.exitstatus}
EOS
      }

      $?.exitstatus
    end
  end
end
