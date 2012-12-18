require 'spec_helper'
describe Reservation do
  let(:reservation) { Reservation.new(summary: "Some test event", start_string: "12/06/2012 12:00", end_string: "12/06/2012 15:00")}
  DATETIME_FORMAT = Time::DATE_FORMATS[:date_time_nosec]
  
  before do
    @room = Room.new(name: "Black", capacity: 20)
    @room.save
    reservation.start = DateTime.strptime(reservation.start_string, DATETIME_FORMAT) - DateTime.local_offset
    reservation.end = DateTime.strptime(reservation.end_string, DATETIME_FORMAT) - DateTime.local_offset
  end
  
  it "must have summary" do
    reservation.summary = nil
    reservation.should_not be_valid
  end
 
  it "is persistable" do
    reservation.should be_valid
    reservation.save
    
    newres = Reservation.find(reservation.id)
    newres.summary.should eq(reservation.summary)
    newres.start.should eq(reservation.start)
    newres.end.should eq(reservation.end)
    newres.room.should eq(reservation.room)
  end
  
  it "must have start" do
    reservation.start = nil
    reservation.start_string = nil
  
    reservation.should_not be_valid
  end
  
  it "must have end" do
    reservation.end = nil
    reservation.end_string = nil
    
    reservation.should_not be_valid
  end
  
  it "must have end after start" do
    reservation.start = DateTime.now
    reservation.end = DateTime.now - 15.minutes
    
    reservation.should_not be_valid
    
    reservation.end = DateTime.now + 15.minutes
    reservation.should be_valid
  end
  
  it "should handle timezones" do
    timezones = ["Hong Kong", "Sydney", "Eastern Time (US & Canada)"]
    start_time = DateTime.now.utc
    end_time = start_time + 30.minutes
    
    timezones.each do |zone|
     reservation.start = start_time.in_time_zone(zone)
     reservation.end = end_time.in_time_zone(zone)
     reservation.save
     
     newres = Reservation.find(reservation.id)
     newres.start.utc.to_datetime.to_s.should eq(start_time.to_s)
     newres.end.utc.to_datetime.to_s.should eq(end_time.to_s)
     
    end
    
  end
  
end
