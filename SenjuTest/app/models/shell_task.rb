class ShellTask < ApplicationRecord
  def execute
    system self.command
    $?.exitstatus == self.expected
  end

  def execute_error
    system self.command
    yield $?.exitstatus if $?.exitstatus != self.expected
  end
end
