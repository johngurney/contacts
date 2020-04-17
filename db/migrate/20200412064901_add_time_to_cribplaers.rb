class AddTimeToCribplaers < ActiveRecord::Migration[5.2]
  def change
    add_column :cribplayers, :lastplay, :datetime
  end
end
