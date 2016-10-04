module Senju::TestCase::RunnerHelper::TaskExecuterHelper
  module TaskExecuter
    # タスクの戻り値、OK/NGでテスト終了したい場合、raise対象になる。
    STATUS_OK = TestExitException.new code: 1
    STATUS_NG = TestExitException.new code: 2
    STATUS_CONT = TestExitException.new code: 0
    STATUS_SKIP = TestExitException.new code: 3
    # ジョブを実行する場合、戻り値とジョブの期待値を環境変数にいれって、次のタスクに渡す。
    SENJU_STATUS = "SENJU_STATUS"
    SENJU_EXPECTED = "SENJU_EXPECTED"

    #
    # タスクの実行結果を連携するクラス
    #
    class TestExitException < 
      attr_accessor :code

      def initialize(code)
        @code = code
      end
    end

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
      IO.popen("ssh #{task.env.user}@#{task.env.host} #{task.exec.type}", "w") do |io|
        io << task.exec.script
      end
    end
  end
end
