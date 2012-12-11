module ReservationsHelper
  
  def reservation_class(reservation)
    if reservation.end.localtime < Time.now
      "pastevent"
    end
  end
  
end
