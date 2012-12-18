require 'spec_helper'

describe User do
  let(:user) { User.new(login: "User", password: "12345789", password_confirmation: "12345789") } 
  
  it "must have login" do
    u = User.new(password: "asjkasd5df-.", password_confirmation: "asjkasd5df-.")
    u.should_not be_valid
  end
  
  it "must have password" do
    u = User.new login: "User123456"
    u.should_not be_valid
  end
  
  it "should be persistable" do
    user.should be_valid
    user.save
    
    newuser = User.find(user.id)
    newuser.login.should eq(user.login)
  end
  
  its "email must be valid" do
    user.email = "somemail@example.vom"
    
    user.should be_valid
  end
end
