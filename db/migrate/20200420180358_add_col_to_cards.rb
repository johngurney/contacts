class AddColToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :game_id, :string
  end
end
