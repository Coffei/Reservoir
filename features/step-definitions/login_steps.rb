Given /^user account that( doesn't)? exist[s]?: ([a-z]+), ([a-z]+)/ do |createnew, login, password|
  if(createnew && !createnew.empty?)
    u = User.new(login: login)
    u.password = password
    u.password_confirmation = password
    u.save
    pp "User created!!"
  end
  
  @login = login
  @password = password
  
end

And /^I am on the homepage/ do
  visit("/")
end

And /^I am on the registration page/ do
  visit("/register")
end


When /^I want to log in$/ do
  fill_in("user_login", with: @login)
  fill_in("user_password", with: @password)
  click_button("Log in")
end

When /^I want to register/ do
  fill_in("user_login", with: @login)
  fill_in("user_password", with: @password)
  fill_in("user_password_confirmation", with: @password)
  click_button("Register")
end

Then /^it should log me in$/ do
  find(".btn .login").text.should eq(@login)
end

Then /^it should register me/ do
  User.where(login: @login).first.should_not be_nil
end
