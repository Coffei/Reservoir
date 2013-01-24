class RemoteCalendar
  def perform
    Room.all.each do |room|
     room.fetch_remote_calendar
    end

    # sleep 10
    # File.open("abcde" + Time.now.to_i.to_s, 'w')

    puts "Remote calendars downloaded."
    Delayed::Job.enqueue(RemoteCalendar.new, run_at: 10.minutes.from_now)
  end

end