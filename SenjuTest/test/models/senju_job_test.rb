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

end
