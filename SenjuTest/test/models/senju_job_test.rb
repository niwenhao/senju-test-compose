require 'test_helper'

class SenjuJobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Insert" do
    cnt = SenjuJob.all().size
    SenjuJob.new(name: "dummy").save()
    assert_equal cnt + 1, SenjuJob.all().size
  end

  test "Association" do
    j = SenjuJob.find_by name: "start"
    assert_equal "ls /", j.preExec.command
    assert_equal "ls /lib", j.postExec.command
    assert_equal "batch", j.senjuEnv.name
  end
end
