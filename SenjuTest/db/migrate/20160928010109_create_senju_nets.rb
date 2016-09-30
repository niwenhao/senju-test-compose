class CreateSenjuNets < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_nets do |t|
      t.string :name
      t.string :description
      t.references :senjuEnv
      t.references :preExec, polymorphic: true
      t.references :postExec, polymorphic: true

      t.timestamps
    end
  end
end
