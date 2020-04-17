class CreateCribplayers < ActiveRecord::Migration[5.2]
  def change
    create_table :cribplayers do |t|
      t.integer :number
      t.string :key

      t.timestamps
    end
  end
end
