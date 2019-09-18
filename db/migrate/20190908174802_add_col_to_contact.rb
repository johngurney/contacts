class AddColToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :rotation, :integer
    change_column_default :contacts, :rotation, 0
  end
end
