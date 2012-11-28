class ChangeStartEndTypeReservation < ActiveRecord::Migration
  def up
    change_column(:reservations, :start, :datetime)
    change_column(:reservations, :end, :datetime)
  end
  
  def down
    change_column(:reservations, :start, :time)
    change_column(:reservations, :end, :time)
  end
end