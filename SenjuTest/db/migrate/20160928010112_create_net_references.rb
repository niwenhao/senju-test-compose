class CreateNetReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :net_references do |t|
      t.references :senjuNet
      t.references :senjuObject, polymorphic: true

      t.timestamps
    end
  end
end
