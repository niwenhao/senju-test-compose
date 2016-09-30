class AddEnvToNetReference < ActiveRecord::Migration[5.0]
  def change
    add_reference :net_references, :senjuEnv
  end
end
