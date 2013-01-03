class Room < ActiveRecord::Base
  has_many :reservations
  attr_accessible :capacity, :equipment, :location, :name, :cal_url
  
  validates :capacity , numericality: true
  validates :name, presence: true, length: { maximum: 100 }
  validate :validate_cal_url
  
  def validate_cal_url
    
  end
  
end
