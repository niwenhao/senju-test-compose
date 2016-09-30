class RemoveTaskFromSenjuJob < ActiveRecord::Migration[5.0]
  def change
    remove_column :senju_jobs, :task_id
    remove_column :senju_jobs, :task_type
  end
end
