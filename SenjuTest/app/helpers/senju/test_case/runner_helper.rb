module Senju::TestCase::RunnerHelper
    class TestCaseExecuter
      attr_accessor :config

      def run
        @readiedObjects = []
        net = SenjuNet.find_by name: @config["net_name"]
        raise "Fail to find net #{@config["net_name"]}" unless net

        execute

      end

      def execute

      end
    end
end
