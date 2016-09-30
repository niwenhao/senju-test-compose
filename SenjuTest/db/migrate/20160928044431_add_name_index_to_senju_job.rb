class AddNameIndexToSenjuJob < ActiveRecord::Migration[5.0]
  def change
    add_index :senju_jobs, :name
  end
end
