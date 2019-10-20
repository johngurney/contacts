class ChangeColInLocationlogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :positionlogs, :user_name
  end
end
