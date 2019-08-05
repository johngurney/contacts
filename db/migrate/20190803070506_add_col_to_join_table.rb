class AddColToJoinTable < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts_sheets, :order, :integer
  end
end
