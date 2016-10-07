class AddEnvRefToSenjuTriger < ActiveRecord::Migration[5.0]
  def change
    add_reference :senju_trigers, :senjuEnv
  end
end
