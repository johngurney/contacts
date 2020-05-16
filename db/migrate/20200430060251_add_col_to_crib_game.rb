class AddColToCribGame < ActiveRecord::Migration[5.2]
  def change
    add_column :cribgames, :freezenewplayers, :boolean
    remove_column :cribplayers, :freezenewplayers, :boolean

  end
end
