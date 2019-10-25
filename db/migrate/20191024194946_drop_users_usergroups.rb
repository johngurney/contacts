class DropUsersUsergroups < ActiveRecord::Migration[5.2]
  def change
    drop_table :users_usergroups
  end
end
