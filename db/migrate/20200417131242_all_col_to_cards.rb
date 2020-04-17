class AllColToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :player, :integer

  end
end
