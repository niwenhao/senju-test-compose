require 'test_helper'

class NetReferenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "Reference" do
    net = SenjuNet.find_by name: "statistics"
    assert net

    assert_equal 3, net.refs.size

    refs = net.netReferences.sort { |a, b| a.senjuObject.name <=> b.senjuObject.name }
    assert_equal "nighttask", refs[0].senjuObject.name
    assert_equal "start", refs[1].senjuObject.name
    assert_equal "timeout", refs[2].senjuObject.name

    night = refs[0]

    assert_equal 2, night.senjuObject.netReferences.size
  end
end
