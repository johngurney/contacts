class AddColsToLocationUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :update_frequency, :integer, default: 1
    add_column :users, :last_posting_within, :integer, default: 1
    add_column :users, :allow_monitoring, :boolean, default: false
  end
end
