class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.text :description
      t.string :email_address
      t.string :tel_number
      t.string :mobile_number
      t.string :url

      t.timestamps
    end
  end
end
