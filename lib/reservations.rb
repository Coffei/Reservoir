module ReservationModule


  def is_running
    return start.localtime <= Time.now && self.end.localtime >= Time.now 
  end
  
  
end