class AddColToFollowing < ActiveRecord::Migration[5.2]
  def change
    add_column :followings, :usergroup_id, :integer
  end
end
