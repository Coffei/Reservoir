class ApplicationController < ActionController::Base
  protect_from_forgery
  
    layout Proc.new { |controller| controller.devise_controller? ? 'empty' : 'application' }
    
    def get_room_reservations_from_calendar(room)
    #download
    unless(room.cal_url.empty?)
      require "net/http"
      
      uri = URI.parse(room.cal_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl=true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request_get(uri.path) do |res|
        @body = res.body
      end
      
      
      #parse
      cal = RiCal.parse_string(@body)
      
      events =  convert_to_reservations(cal, room)
      
      return events
    end
  end
  
  private
  def convert_to_reservations(calendar, room)
    events = calendar.first.events
    events = events.map { |event| Reservation.new(summary: event.summary,
                         description: event.description, start: event.dtstart,
                         end: event.dtend) }
    events.each do |event|
      event.room = room
    end
  end
end
