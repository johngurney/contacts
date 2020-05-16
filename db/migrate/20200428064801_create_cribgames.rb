class CreateCribgames < ActiveRecord::Migration[5.2]
  def change
    create_table :cribgames do |t|
      t.boolean :hasstarted
      t.string :game_id

      t.timestamps
    end
  end
end
