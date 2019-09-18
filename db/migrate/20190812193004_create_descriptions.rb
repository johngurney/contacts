class CreateDescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :descriptions do |t|
      t.text :desc
      t.integer :contact_id
      t.string :name

      t.timestamps
    end
  end
end
