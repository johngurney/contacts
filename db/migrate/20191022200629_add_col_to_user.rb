class AddColToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :map_name, :string
  end
end
