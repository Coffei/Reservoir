class TempReservation < ActiveRecord::Base
  
  include ReservationModule
  
  belongs_to :room
  attr_accessible :description, :end, :start, :summary, :start_string, :end_string
  attr_accessor :start_string, :end_string
  
  
  scope :between, lambda {|start,end_date| where("\"end\" >= ? AND \"start\" <= ?", start.utc, end_date.utc) }
  scope :of, lambda {|room| where(:room_id => room.id)}
  scope :after, lambda {|start_time| where("\"end\" >= ?", Reservation.format_date(start_time))}
  scope :before, lambda {|end_time| where("\"start\" < ?", Reservation.format_date(end_time))}
  
  def author
    nil
  end
  
  def author_id
    nil
  end
  
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.summary,
      :description => self.description,
      :start => self.start.rfc822,
      :end => self.end.rfc822,
      :allDay => false,
      :room => (self.room ? self.room.as_json : "" ),
      :author => self.author.as_json,
      :url => (self.id ? Rails.application.routes.url_helpers.room_reservation_path(self.room, self) : "")
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
      :author_id => self.author.id
    }
  end
  
end