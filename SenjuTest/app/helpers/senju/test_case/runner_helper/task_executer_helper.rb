module Senju::TestCase::RunnerHelper::TaskExecuterHelper
  module TaskExecuter
    STATUS_OK = TestExitException.new code: 1
    STATUS_NG = TestExitException.new code: 2
    STATUS_CONT = TestExitException.new code: 0
    STATUS_SKIP = TestExitException.new code: 3
    SENJU_STATUS = "SENJU_STATUS"
    SENJU_EXPECTED = "SENJU_EXPECTED"

    class TestExitException < 
      attr_accessor :code

      def initialize(code)
        @code = code
      end
    end

    def execute_task(task)
      IO.popen("ssh #{task.env.user}@#{task.env.host} #{task.exec.type}", "w") do |io|
        io << task.exec.script
      end
    end
  end
end
