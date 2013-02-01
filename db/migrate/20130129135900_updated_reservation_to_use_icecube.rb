class UpdatedReservationToUseIcecube < ActiveRecord::Migration
  
  def up
  remove_column(:reservations, :interval)
  remove_column(:reservations, :repeat_until)
  add_column(:reservations, :scheduleyaml, :text)
  
  remove_column(:temp_reservations, :interval)
  remove_column(:temp_reservations, :repeat_until)
  add_column(:temp_reservations, :scheduleyaml, :text)
  end
  
  def down
    add_column(:reservations, :interval, :integer)
    add_column(:reservations, :repeat_until, :datetime)
    remove_column(:reservations, :scheduleyaml)
    
    add_column(:temp_reservations, :interval, :integer)
    add_column(:temp_reservations, :repeat_until, :datetime)
    remove_column(:temp_reservations, :scheduleyaml)
  end
  
  
end