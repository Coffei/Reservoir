Feature: Login

As a user, I want to be able to login with my account credentials

Scenario: Login possible from homepage
	Given user account that exists: test, test
	And I am on the homepage
	When I want to log in
	Then it should log me in 

Scenario: Registration possible
	Given user account that doesn't exist: testlogin, testpassword
	And I am on the registration page
	When I want to register
	Then it should register me
	Then it should log me in