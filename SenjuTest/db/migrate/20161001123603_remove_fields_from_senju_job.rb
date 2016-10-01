class RemoveFieldsFromSenjuJob < ActiveRecord::Migration[5.0]
  def change
    remove_column :senju_jobs, :preExec_id
    remove_column :senju_jobs, :preExec_type
    remove_column :senju_jobs, :postExec_id
    remove_column :senju_jobs, :postExec_type
  end
end
