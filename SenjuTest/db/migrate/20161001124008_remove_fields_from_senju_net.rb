class RemoveFieldsFromSenjuNet < ActiveRecord::Migration[5.0]
  def change
    remove_column :senju_nets, :preExec_id
    remove_column :senju_nets, :preExec_type
    remove_column :senju_nets, :postExec_id
    remove_column :senju_nets, :postExec_type
  end
end
