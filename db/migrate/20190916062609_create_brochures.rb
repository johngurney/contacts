class CreateBrochures < ActiveRecord::Migration[5.2]
  def change
    create_table :brochures do |t|
      t.binary :content
      t.binary :image

      t.timestamps
    end
  end
end
