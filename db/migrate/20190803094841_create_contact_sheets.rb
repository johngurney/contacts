class CreateContactSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_sheets do |t|
      t.integer :sheet_id
      t.integer :contact_id
      t.integer :order

      t.timestamps
    end
  end
end
