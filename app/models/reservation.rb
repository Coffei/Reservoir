class Reservation < ActiveRecord::Base
  belongs_to :room
  belongs_to :author, :class_name => "User"
  attr_accessible :description, :end, :start, :summary, :start_string, :end_string
  attr_accessor :start_string, :end_string
  
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
  
  scope :between, lambda {|start,end_date| where("end >= ? AND start <= ?", start.utc, end_date.utc) }
  scope :of, lambda {|room| where(:room_id => room.id)}
  
  def is_running
    return start <= Time.now && self.end >= Time.now 
  end
end
