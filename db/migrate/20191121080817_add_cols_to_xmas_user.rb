class AddColsToXmasUser < ActiveRecord::Migration[5.2]
  def change
    add_column :xmas_users, :latitude, :decimal
    add_column :xmas_users, :longitude, :decimal
  end
end
