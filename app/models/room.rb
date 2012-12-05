class Room < ActiveRecord::Base
  has_many :reservations
  attr_accessible :capacity, :equipment, :location, :name
  
  validates :capacity , numericality: true
  validates :name, presence: true, length: { maximum: 100 }
  
  def as_json
    {
      :id => self.id,
      :name => self.name
    }
  end
  
end
