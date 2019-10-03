class AddColToLog < ActiveRecord::Migration[5.2]
  def change
    add_column :logs, :sheet_id, :integer
  end
end
