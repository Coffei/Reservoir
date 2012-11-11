class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :room
      t.references :author
      t.time :start
      t.time :end
      t.text :description
      t.string :summary

      t.timestamps
    end
    add_index :reservations, :room_id
    add_index :reservations, :author_id
  end
end
