class RemoveFieldsFromSenjuTriger < ActiveRecord::Migration[5.0]
  def change
    remove_column :senju_trigers, :postExec_id
    remove_column :senju_trigers, :postExec_type
  end
end
