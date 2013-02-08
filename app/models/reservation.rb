class Reservation < ActiveRecord::Base

  include ReservationModule
  

  belongs_to :room
  belongs_to :author, :class_name => "User"
  attr_accessible :description, :end, :start, :summary, :scheduleyaml, :start_string, :end_string
  attr_accessor :start_string, :end_string, :schedule

  validates :summary, :presence => true, :length => {:maximum => 150}
  validates :start_string, presence: true
  validates :end_string, presence: true
  validate :start_before_end
  def start_before_end
    if start && self.end &&  start >= self.end
      errors.add(:start_string, "must be before end")
      errors.add(:end_string, "must be after start")
    end
  end

  scope :between, lambda {|start,end_date| where("(\"end\" >= ? AND \"start\" <= ?) OR (scheduleyaml IS NOT NULL)", start.utc, end_date.utc) }
  scope :of, lambda {|room| where(:room_id => room.id)}
  scope :after, lambda {|start_time| where("(\"end\" >= ?) OR (scheduleyaml IS NOT NULL)", Reservation.format_date(start_time))}
  scope :before, lambda {|end_time| where("(\"start\" < ?)", Reservation.format_date(end_time))}

  def self.format_date(date_time)
    Time.at(date_time.to_i).utc.to_formatted_s(:db)
  end

  def sid
    "native" + id.to_s
  end

  def type
    :native
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
      @schedule = Schedule.from_yaml(self.scheduleyaml)
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
      :author => self.author.as_json,
      :url => (self.id ? Rails.application.routes.url_helpers.room_reservation_path(self.room, self) : ""),
      :type => "native"
    }
  end
  
  def as_public_json
    {
      :title => self.summary,
      :description => self.description,
      :start => self.start.rfc822,
      :end => self.end.rfc822,
      :allDay => false,
      :room_id => self.room.id,
      :author_id => self.author.id,
      :type => "native"
    }
  end
end
