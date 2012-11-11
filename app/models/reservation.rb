class Reservation < ActiveRecord::Base
  belongs_to :room
  belongs_to :user
  attr_accessible :description, :end, :start, :summary
  
  validates :summary, :presence => true, :length => {:maximum => 150}
  validates :start, presence: true
  validates :end, presence: true
end
