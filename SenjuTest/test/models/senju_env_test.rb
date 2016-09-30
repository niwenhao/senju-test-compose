require 'test_helper'

class SenjuEnvTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  #
    
  setup do
    SenjuEnv.new(name: "testadd", logonUser: "testadduser", hostName: "testaddhost").save()
  end
  test "Insert" do
    oldsize = SenjuEnv.all.size
    SenjuEnv.new(name: "testadd", logonUser: "testadduser", hostName: "testaddhost").save()
    assert_equal oldsize + 1, SenjuEnv.all().size
  end

  test "Select" do
    e = SenjuEnv.find_by(name: "testadd")
    assert_equal "testadduser", e.logonUser
    assert_equal "testaddhost", e.hostName
  end
end
