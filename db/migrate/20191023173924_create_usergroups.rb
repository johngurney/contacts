class CreateUsergroups < ActiveRecord::Migration[5.2]
  def change
    create_table :usergroups do |t|
      t.string :name
      t.boolean :bespoke
      t.decimal :north
      t.decimal :south
      t.decimal :west
      t.decimal :east
      t.boolean :draggable

      t.timestamps
    end
  end
end
