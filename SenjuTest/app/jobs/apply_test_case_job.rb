class ApplyTestCaseJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    testcase = args[0]

    tconfig = YAML.load(File.new(testcase))

  end
end
