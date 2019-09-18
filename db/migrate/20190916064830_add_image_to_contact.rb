class AddImageToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :image, :binary
  end
end
