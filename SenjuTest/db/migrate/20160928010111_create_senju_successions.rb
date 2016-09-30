class CreateSenjuSuccessions < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_successions do |t|
      t.references :left
      t.references :right
      t.references :task

      t.timestamps
    end
  end
end
