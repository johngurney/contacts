class AddDescColToJoinTable < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_sheets, :description_id, :integer
  end
end
