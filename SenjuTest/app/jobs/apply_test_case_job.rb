class ApplyTestCaseJob < ApplicationJob
  include Senju::CommonLogHelper
  include Senju::TestCase::RunnerHelper
  include Senju::CommonHelper

  queue_as :default

  def perform(*args)
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

  end
end
