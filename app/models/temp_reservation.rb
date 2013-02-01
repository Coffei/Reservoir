class TempReservation < ActiveRecord::Base
  COLOR = "#308045"  
  include ReservationModule
  
  
  belongs_to :room
  attr_accessible :description, :end, :start, :summary, :start_string, :end_string, :scheduleyaml
  attr_accessor :schedule
  
  
  scope :between, lambda {|start,end_date| where("(\"end\" >= ? AND \"start\" <= ?) OR (scheduleyaml IS NOT NULL)", start.utc, end_date.utc) }
  scope :of, lambda {|room| where(:room_id => room.id)}
  scope :after, lambda {|start_time| where("(\"end\" >= ?) OR (scheduleyaml IS NOT NULL)", Reservation.format_date(start_time))}
  scope :before, lambda {|end_time| where("(\"start\" < ?)", Reservation.format_date(end_time))}
  
  def author
  end
  def author=(author)
  end
  def author_id
  end
  def author_id=(value)
  end
  
  
  def sid
    "remote" + id.to_s
  end
  
  def type
    :remote
  end
  
 #callbacks
  before_save do
    if(@schedule)
      self.scheduleyaml = @schedule.to_yaml
    else
      self.scheduleyaml = nil
    end 
  end
  
  after_initialize do
    if(self.scheduleyaml)
      @schedule = Schedule.from_yaml self.scheduleyaml
    end
  end
  
  
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.summary,
      :description => self.description,
      :start => self.start.localtime.rfc822,
      :end => self.end.localtime.rfc822,
      :recurrence => (self.recurs? ? self.schedule.to_s : nil),
      :allDay => false,
      :room => (self.room ? self.room.as_json : "" ),
      :type => "remote",
      :color => COLOR
    }
  end
  
  def as_public_json
    {
      :title => self.summary,
      :description => self.description,
      :start => self.start.rfc822,
      :end => self.end.rfc822,
      :room_id => self.room.id,
      :type => "remote"
    }
  end
  
end