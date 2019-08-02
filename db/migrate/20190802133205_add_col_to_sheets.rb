class AddColToSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :sheets, :number, :string
  end
end
