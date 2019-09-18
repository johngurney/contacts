class CreateConshejointables < ActiveRecord::Migration[5.2]
  def change
    create_table :conshejointables do |t|
      t.integer :contact_id, default: 0
      t.integer :sheet_id, default: 0
      t.integer :order_number, default: 0

      t.timestamps
    end
  end
end
