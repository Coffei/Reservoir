class AddRecurrenceParamsToReservation < ActiveRecord::Migration
  def up
    add_column(:reservations, :interval, :integer)
    add_column(:reservations, :repeat_until, :datetime)
    
    add_column(:temp_reservations, :interval, :integer)
    add_column(:temp_reservations, :repeat_until, :datetime)
  end
  
  def down
    remove_column(:reservations, :interval, :repeat_until)
    remove_column(:temp_reservations, :interval, :repeat_until)
  end
end