class AddColToBrochure < ActiveRecord::Migration[5.2]
  def change
    add_column :brochures, :name, :string
  end
end
