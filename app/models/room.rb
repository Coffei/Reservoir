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

    else
      clean_cal()
    end
  end

  private

  def convert_single_temp_reservation(event)
    res = TempReservation.new(summary: event.summary,
    description: event.description, start: Time.zone.at(event.start_time.to_i),
    end: Time.zone.at(event.finish_time.to_i))
    res.room = self

    #build schedule
    if(event.recurs?)
      res.schedule = IceCube::Schedule.new(res.start, end_time: res.end)
      
      event.rrule_property.each do |rrule|
        interval = rrule.interval
        interval = 1 unless(interval)
        # create rule by freq and interval
        case rrule.freq
        when "SECONDELY"; rule = IceCube::Rule.secondly(interval)
        when "MINUTELY"; rule = IceCube::Rule.minutely(interval)
        when "HOURLY"; rule = IceCube::Rule.hourly(interval)
        when "DAILY"; rule = IceCube::Rule.daily(interval)
        when "WEEKLY"; rule = IceCube::Rule.weekly(interval)
        when "MONTHLY"; rule = IceCube::Rule.monthly(interval)
        when "YEARLY"; rule = IceCube::Rule.yearly(interval)
        end

        #additional rec. limitation
        rrule.by_list.each do |name, value|
          case name
          when :bymonth; rule.month_of_year(*value)
          when :byday; parsebyday(rule, value)
          when :bymonthday; rule.day_of_month(*value.map(&:ordinal))
          when :byyearday; rule.day_of_year(*value.map(&:ordinal))
          when :byhour; rule.hour_of_day(*value)
          when :byminute; rule.minute_of_hour(*value)
          #:byweekno  is not implemented, has no impl. in ice_cube
          #:bysetpos; is not implemented, has no impl. in ice_cube    
          end
        end

        #recurrence limitation
        rule.until(rrule.until.to_datetime) if rrule.until
        rule.count(rrule.count.to_datetime) if rrule.count
          
          
        #add rrule
        res.schedule.add_recurrence_rule rule
      end
    end

    res
  end

  def parsebyday(rule, value)
    valueregex = /-?\d+\D+/
    if(value.first.to_s =~ valueregex)
      rule.day_of_week(to_days_range(value))
    else
      rule.day(*to_days(value))
    end
  end

  def to_days(values)
    values.map do |value|
      parse_day(value.to_s.match(/[a-zA-Z]+/)[0])
    end
  end

  def parse_day(day)
    case day
    when "MO"; :monday
    when "TU"; :tuesday
    when "WE"; :wednesday
    when "TH"; :thursday
    when "FR"; :friday
    when "SA"; :saturday
    when "SU"; :sunday
    end
  end

  #possible loss of data when merging hashes
  def to_days_range(values)
    values.map do |value|
      match = value.to_s.match(/(-?\d+)(\D+)/)
      { parse_day(match[2]) => [match[1].to_i] }
    end.reduce(&:merge)
  end

  def store_cal(cal)
    #delete old
    puts "Deleting old temps"
    ActiveRecord::Base.transaction do
      TempReservation.of(self).delete_all

      #store current
      puts "Storing new temps #{cal.first.events.count}"

      cal.first.events.each do |event|
        convert_single_temp_reservation(event).save

        ActiveRecord::Base.connection.execute("UPDATE temp_reservations SET description = '' WHERE description IS NULL")
        ActiveRecord::Base.connection.execute("UPDATE temp_reservations SET summary = '' WHERE summary IS NULL")
      end
    end
  end

  def clean_cal
    puts "Deleting all temps"
    TempReservation.of(self).delete_all
  end
end

