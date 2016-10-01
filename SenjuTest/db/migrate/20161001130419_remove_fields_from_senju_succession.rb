class RemoveFieldsFromSenjuSuccession < ActiveRecord::Migration[5.0]
  def change
    remove_column :senju_successions, :task_id, :integer
  end
end
