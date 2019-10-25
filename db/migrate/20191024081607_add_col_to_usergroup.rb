class AddColToUsergroup < ActiveRecord::Migration[5.2]
  def change
    add_column :usergroups, :url, :string
  end
end
