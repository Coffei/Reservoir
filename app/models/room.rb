class Room < ActiveRecord::Base
  has_many :reservations
  attr_accessible :capacity, :equipment, :location, :name, :cal_url
  attr_accessor :remote_last_updated
  
  validates :capacity , numericality: true
  validates :name, presence: true, length: { maximum: 100 }
  validate :validate_cal_url
  
  def validate_cal_url
    #TODO
  end
  
  def fetch_remote_calendar
    #download
    unless(cal_url.empty?)
      require "net/http"
      
      uri = URI.parse(cal_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl=true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request_get(uri.path) do |res|
        cal = RiCal.parse_string(res.body)
        store_cal(cal)
      end
      
    end
  end
  
 
  private
  def convert_to_temp_reservations(calendar, params={})
    if params == {}
      params = {count: 100}
    end
    events = calendar.first.events.map { |event| convert_single_temp_reservation(event) } #TODO: check posibility of doubling the first occurence of recurring event
    calendar.first.events.select { |event| event.recurs? }.each do |event|
      events.concat(event.occurrences(params).map { |res| convert_single_reservation(res)})
    end
    
  end
  
  def convert_single_temp_reservation(event) 
    res = TempReservation.new(summary: event.summary,
                          description: event.description, start: event.dtstart.to_datetime,
                          end: event.dtend.to_datetime)
    res.room = self
    
    res
  end
  
  def store_cal(cal)
    #delete old
    puts "Deleting old temps"
    TempReservation.of(self).delete_all
    
    #store current
    puts "Storing new temps #{cal.first.events.count}"
    ActiveRecord::Base.transaction do
    cal.first.events.each do |event|
      if(event.recurs?)
        event.occurrences(count: 300).each { |re_event| convert_single_temp_reservation(re_event).save }
      else
        convert_single_temp_reservation(event).save
      end
      
      ActiveRecord::Base.connection.execute("UPDATE temp_reservations SET description = '' WHERE description IS NULL")
      ActiveRecord::Base.connection.execute("UPDATE temp_reservations SET summary = '' WHERE summary IS NULL")
      
    end
   end
  end
  
 
end



