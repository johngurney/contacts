class CreateLocationLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :locationlogs do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.integer :user_id
    end
  end
end
