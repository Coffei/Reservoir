class Reservation < ActiveRecord::Base
  belongs_to :room
  belongs_to :user
  attr_accessible :description, :end, :start, :summary
end
