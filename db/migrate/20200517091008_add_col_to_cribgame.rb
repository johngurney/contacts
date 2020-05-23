class AddColToCribgame < ActiveRecord::Migration[5.2]
  def change
    add_column :cribgames, :whosecrib, :integer
  end
end
