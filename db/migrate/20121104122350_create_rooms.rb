class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :capacity
      t.string :location
      t.string :equipment

      t.timestamps
    end
  end
end
