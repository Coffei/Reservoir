class ChangeStartEndTypeReservation < ActiveRecord::Migration
  def up
    remove_column(:reservations, :start)
    remove_column(:reservations, :end)
    add_column(:reservations, :start, :datetime)
    add_column(:reservations, :end, :datetime)
  end
  
  def down
    remove_column(:reservations, :start)
    remove_column(:reservations, :end)
    add_column(:reservations, :start, :time)
    add_column(:reservations, :end, :time)
  end
end