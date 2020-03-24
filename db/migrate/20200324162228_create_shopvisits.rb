class CreateShopvisits < ActiveRecord::Migration[5.2]
  def change
    create_table :shopvisits do |t|
      t.string :user
      t.datetime :visitdate
      t.integer :visit_time

      t.timestamps
    end
  end
end
