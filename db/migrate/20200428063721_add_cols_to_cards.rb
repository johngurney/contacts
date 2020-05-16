class AddColsToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cribplayers, :redealrequest, :datetime
    add_column :cribplayers, :resetrequest, :datetime
  end
end
