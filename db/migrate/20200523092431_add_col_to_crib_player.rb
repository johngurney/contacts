class AddColToCribPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :cribplayers, :ismobile, :boolean
  end
end
