require 'test_helper'

class ShellTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "insert" do
    ShellTask.new(command: "ls /etc", expected: 0).save()
    assert ShellTask.all.size == 3
  end

  test "execute" do
    t = ShellTask.new(command: "ls /tmp", expected: 0)
    assert t.execute
    t.expected = 1
    assert ! t.execute
  end

  test "execute_error" do
    f = 0
    t = ShellTask.new(command: "ls /tmp", expected: 0)
    t.execute_error do |status|
      assert false
    end

    t.command = "/salkflkaslkaslk"
    t.execute_error do |status|
      f = status
    end
    assert f != 0
  end
end
