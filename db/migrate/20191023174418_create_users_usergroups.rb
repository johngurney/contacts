class CreateUsersUsergroups < ActiveRecord::Migration[5.2]
  def change
    create_table :users_usergroups do |t|
      t.integer :user_id
      t.integer :user_group_id

      t.timestamps
    end
  end
end
