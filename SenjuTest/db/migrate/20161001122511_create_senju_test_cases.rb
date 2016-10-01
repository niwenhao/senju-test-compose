class CreateSenjuTestCases < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_test_cases do |t|
      t.string :name
      t.string :owner
      t.references :preTask, polymorphic: true
      t.references :postTask, polymorphic: true

      t.timestamps
    end
  end
end
