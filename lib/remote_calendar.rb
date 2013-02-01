class RemoteCalendar < Struct.new(:room_id)
  def perform
    if(room_id)
      Room.where(id: room_id).each do |room|
        room.fetch_remote_calendar
      end
      # no rescheduling
      puts "Remote calendar updated."
    else
      Room.all.each do |room|
      room.fetch_remote_calendar
    end
      puts "Remote calendars updated."
      Delayed::Job.enqueue(RemoteCalendar.new, run_at: 10.minutes.from_now)
    end
  end

end