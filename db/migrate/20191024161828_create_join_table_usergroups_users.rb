class CreateJoinTableUsergroupsUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :usergroups, :users do |t|
      t.index [:usergroup_id, :user_id]
      t.index [:user_id, :usergroup_id]
    end
  end
end
