class ChangeTableName < ActiveRecord::Migration[5.2]
  def change
    rename_table :contact_sheets, :contacts_sheets
  end
end
