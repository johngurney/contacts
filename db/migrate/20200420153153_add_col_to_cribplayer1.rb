class AddColToCribplayer1 < ActiveRecord::Migration[5.2]
  def change
    add_column :cribplayers, :name, :string
    add_column :cribplayers, :game_id, :string
    add_column :cribplayers, :freezenewplayers, :boolean
  end
end
