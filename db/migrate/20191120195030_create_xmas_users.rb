class CreateXmasUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :xmas_users do |t|
      t.string :token
      t.integer :stage

      t.timestamps
    end
  end
end
