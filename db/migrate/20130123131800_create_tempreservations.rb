class CreateTempreservations < ActiveRecord::Migration
  
  def up
    create_table :temp_reservations do |t|
      t.references :room
      t.datetime :start
      t.datetime :end
      t.text :description
      t.string :summary

      t.timestamps
    end
    add_index :temp_reservations, :room_id
  end
  
  def down
    drop_table :temp_reservations
  end
  
end