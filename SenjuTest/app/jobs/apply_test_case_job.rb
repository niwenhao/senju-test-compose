class ApplyTestCaseJob < ApplicationJob
  include Senju::CommonLogHelper
  include Senju::TestCase::RunnerHelper
  include Senju::TestCase::RunnerHelper::TaskExecuterHelper::TaskExecuter
  include Senju::CommonHelper

  queue_as :default

  def perform(*args)

    begin
      # Do something later
      testcase = args[0]
      info { "Testcase file => #{testcase}" }

      tconfig = YAML.load(File.new(testcase))

      tconfig.each do |key, value|
        info { "Testcase #{key} begin" }

        t = TestCaseExecuter.new(ConfigContext.new(value))
        t.start

        info { "Testcase #{key} normal end" }
      end
    rescue TestExitException => e then
      if e.code == STATUS_NG.code then
        info "TEST failed"
        exit 100
      end
    end
  end
end
