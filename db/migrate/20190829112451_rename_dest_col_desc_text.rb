class RenameDestColDescText < ActiveRecord::Migration[5.2]
  def change
    rename_column :descriptions, :desc, :text
  end
end
