class CreateBroshejointables < ActiveRecord::Migration[5.2]
  def change
    create_table :broshejointables do |t|
      t.integer :sheet_id
      t.integer :brochure_id
      t.integer :order_number

      t.timestamps
    end
  end
end
