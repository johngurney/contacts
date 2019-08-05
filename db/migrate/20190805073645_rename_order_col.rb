class RenameOrderCol < ActiveRecord::Migration[5.2]
  def change
    rename_column :contact_sheets, :order, :order_number
  end
end
