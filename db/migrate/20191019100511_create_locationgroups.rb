class CreateLocationgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :locationgroups do |t|
      t.string :name

      t.timestamps
    end
  end
end
