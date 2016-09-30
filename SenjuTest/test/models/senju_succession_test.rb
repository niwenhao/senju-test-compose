require 'test_helper'

class SenjuSuccessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Asso" do
    top = SenjuNet.find_by name: "statistics"

    startrefs = top.netReferences.select { |r| r.left.size == 0 }
    assert_equal 1, startrefs.size
    start = startrefs.first
    assert_equal "nighttask", start.right.first.senjuObject.name
    assert_equal "start", start.right.first.right.first.senjuObject.name
  end
end
