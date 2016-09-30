class CreateSenjuTrigers < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_trigers do |t|
      t.string :name
      t.string :description
      t.string :node
      t.string :path
      t.references :postExec, polymorphic: true

      t.timestamps
    end
  end
end
