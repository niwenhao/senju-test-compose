class CreateSenjuEnvs < ActiveRecord::Migration[5.0]
  def change
    create_table :senju_envs do |t|
      t.string :logonUser
      t.string :hostName

      t.timestamps
    end
  end
end
