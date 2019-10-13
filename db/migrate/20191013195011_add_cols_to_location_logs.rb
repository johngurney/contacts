class AddColsToLocationLogs < ActiveRecord::Migration[5.2]
  def change
    def change_table
        add_column :locationlogs, :created_at, :datetime, null: false
        add_column :locationlogs, :updated_at, :datetime, null: false
      end
  end
end
