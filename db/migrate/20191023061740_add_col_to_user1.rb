class AddColToUser1 < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trace, :boolean
  end
end
