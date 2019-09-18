class RemoveDescColFromContact < ActiveRecord::Migration[5.2]
  def change
    remove_column :contacts, :description
  end
end
