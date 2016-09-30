require 'test_helper'

class SenjuNetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Insert" do
    cnt = SenjuNet.all.size

    assert (j = SenjuNet.new()).save

    assert_equal cnt + 1, SenjuNet.all.size
  end

  test "association" do
    j = SenjuNet.find_by name: "nighttask"
    assert_equal "Process in night", j.description
    assert_equal "batch", j.senjuEnv.name
  end
end
