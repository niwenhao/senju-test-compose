class AddNameToSenjuEnv < ActiveRecord::Migration[5.0]
  def change
    add_column :senju_envs, :name, :string
    add_index :senju_envs, :name
  end
end
