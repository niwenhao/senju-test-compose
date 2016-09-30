class CreateSenjuJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_jobs do |t|
      t.string :name
      t.string :description
      t.string :command
      t.integer :expected
      t.references :senjuEnv
      t.references :task, polymorphic: true
      t.references :preExec, polymorphic: true
      t.references :postExec, polymorphic: true

      t.timestamps
    end
  end
end
