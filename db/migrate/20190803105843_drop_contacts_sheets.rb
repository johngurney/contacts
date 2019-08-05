class DropContactsSheets < ActiveRecord::Migration[5.2]
  def change
    drop_table :contacts_sheets
  end
end
