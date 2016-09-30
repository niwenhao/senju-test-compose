class AddNameIndexToSenjuNet < ActiveRecord::Migration[5.0]
  def change
    add_index :senju_nets, :name
    add_index :senju_trigers, :name
  end
end
