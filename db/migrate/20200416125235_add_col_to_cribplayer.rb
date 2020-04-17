class AddColToCribplayer < ActiveRecord::Migration[5.2]
  def change
    add_column :cribplayers, :score, :integer
  end
end
