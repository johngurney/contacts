class AddColToPositionLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :positionlogs, :user_name, :string
  end
end
