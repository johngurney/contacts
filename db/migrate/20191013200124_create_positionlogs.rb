class CreatePositionlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :positionlogs do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.integer :user_id

      t.timestamps
    end
  end
end
