class RenameColInCards < ActiveRecord::Migration[5.2]
  def change
    rename_column :cards, :player, :player_id
  end
end
