class AddCol < ActiveRecord::Migration[5.2]
  def change
    add_column :conshejointables, :description_id, :integer
  end
end
