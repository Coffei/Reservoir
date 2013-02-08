class RemoteCalendar < Struct.new(:room_id, :repeat)
  INTERVAL = 30.minutes
  
  def initialize(*args)
    self.repeat = true
    self.room_id = args[0] if args.count >= 1
    self.repeat = args[1] if args.count >= 2
  end
  
  def perform
    if(room_id)
      Room.where(id: room_id).each do |room|
        room.fetch_remote_calendar
      end
      # no rescheduling
      puts "Remote calendar updated."
      if(repeat)
        Delayed::Job.enqueue(RemoteCalendar.new(room_id), run_at: INTERVAL.from_now)
      end
    else
      Room.all.each do |room|
        Delayed::Job.enqueue(RemoteCalendar.new(room.id), run_at: Time.now)
      end
      puts "Remote calendars updated."
    end
  end
  
  
  

end