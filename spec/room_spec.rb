require 'spec_helper'
describe Room do
  
  let(:room) { Room.new(name: "Black", capacity: 10) }
  
  it "must have name" do
    r = Room.new(capacity: 20)  
    r.should_not be_valid
  end
  
  it "must have capacity" do
    r = Room.new(name: "Black")
    r.should_not be_valid
  end
  
  it "is persistable" do
    room.should be_valid
    room.save
    
    newroom = Room.find(room.id)
    newroom.name.should eq(room.name)
    newroom.capacity.should eq(room.capacity)
  end
  
end
