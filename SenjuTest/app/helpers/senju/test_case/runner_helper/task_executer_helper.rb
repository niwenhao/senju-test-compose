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
    STATUS_OK = TestExitException.new 1
    STATUS_NG = TestExitException.new 2
    STATUS_CONT = TestExitException.new 0
    STATUS_SKIP = TestExitException.new 3
    # ジョブを実行する場合、戻り値とジョブの期待値を環境変数にいれって、次のタスクに渡す。
    SENJU_STATUS = "SENJU_STATUS"
    SENJU_EXPECTED = "SENJU_EXPECTED"

    ENV["OK"] = STATUS_OK.code.to_s
    ENV["NG"] = STATUS_NG.code.to_s
    ENV["CONTINUE"] = STATUS_CONT.code.to_s
    ENV["SKIP"] = STATUS_SKIP.code.to_s

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

      if task.env.nil? then
        IO.popen("#{task.exec.type}", "w") do |io|
          io << task.exec.script
        end
      else
        IO.popen("ssh -o \"SendEnv=OK NG SKIP CONTINUE\" #{task.env.user}@#{task.env.host} #{task.exec.type}", "w") do |io|
          io << task.exec.script
        end
      end
      $?.exitstatus
    end
  end
end
