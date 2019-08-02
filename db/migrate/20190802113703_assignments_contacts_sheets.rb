class AssignmentsContactsSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts_sheets, :id => false do |t|
      t.integer :contact_id
      t.integer :sheet_id
    end
  end
end
