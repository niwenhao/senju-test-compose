class CreateShellTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :shell_tasks do |t|
      t.string :command
      t.integer :expected

      t.timestamps
    end
  end
end
