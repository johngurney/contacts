class AddPasswordToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :sheets, :password, :string
  end
end
