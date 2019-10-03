class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.string :ip_address

      t.timestamps
    end
  end
end
