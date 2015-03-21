### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :name => "Testy McUserton", :email => "example@example.com",
    :password => "changeme", :password_confirmation => "changeme",
    :organization_id => 999, :role => "USER"}
  create_visitor_organization
end

def create_admin_visitor
  @visitor ||= { :name => "Admin McUserton", :email => "admin@example.com",
    :password => "changeme", :password_confirmation => "changeme",
    :organization_id => 999, :role => "ADMIN"}
  create_visitor_organization
end

def create_visitor_organization
  @visitor_organization ||= { :name => "Testicorp", :id => 999 }
end

def find_user
  @user ||= User.where(:email => @visitor[:email]).first
end

def find_organization
  @organization ||= Organization.where(:name => @visitor_organization[:name]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user
  create_visitor
  delete_user
  @organization = FactoryGirl.create(:organization, @visitor_organization)
  @user = FactoryGirl.create(:user, @visitor)
end

def create_admin
  create_admin_visitor
  delete_user
  @organization = FactoryGirl.create(:organization, @visitor_organization)
  @visitor.merge(:role => "ADMIN")
  @user = FactoryGirl.create(:admin, @visitor)
end

def delete_user
  @user ||= User.where(:email => @visitor[:email]).first
  @user.destroy unless @user.nil?
  delete_organization
end

def delete_organization
  @organization ||= Organization.where(:name => @visitor_organization[:name]).first
  @organization.destroy unless @organization.nil?
end

def fill_org_with_users
  @org1 = @user.organization
  @user1 = FactoryGirl.create(:user, organization: @org1)
  @admin1 = FactoryGirl.create(:admin, organization: @org1)
end

def sign_up
  delete_user
  visit '/users/sign_up'
  fill_in "user_name", :with => @visitor[:name]
  fill_in "user_email", :with => @visitor[:email]
  fill_in "user_password", :with => @visitor[:password]
  fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
  fill_in "user_organization_attributes_name", :with => @visitor_organization[:name]
  click_button "Sign up"
  find_organization
  find_user
end

def sign_in
  visit '/users/sign_in'
  fill_in "user_email", :with => @visitor[:email]
  fill_in "user_password", :with => @visitor[:password]
  click_button "Log in"
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I exist as an organization admin$/ do
  create_admin
end

Given /^I do not exist as an organization admin$/ do
  create_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign in with valid admin credentials$/ do
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up without a name$/ do
  create_visitor
  @visitor = @visitor.merge(:name => "")
  sign_up
end

When /^I sign up without an organization name$/ do
  create_visitor
  @visitor_organization = @visitor_organization.merge(:name => "")
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "changeme123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link "Edit account"
  fill_in "user_name", :with => "newname"
  fill_in "user_current_password", :with => @visitor[:password]
  click_button "Update"
end

When /^I look at the list of users$/ do
  visit '/'
end

When /^I go to add a user to my organization$/ do
  visit 'users/'
end

When /^I add a user with no name$/ do
  visit 'users/'
  fill_in "Name", :with => ""
  fill_in "Email", :with => "anewuser@example.com"
  click_button "Add User"
end

When /^I add a user with invalid email$/ do
  visit 'users/'
  fill_in "Name", :with => "New User"
  fill_in "Email", :with => "invalidemail.com"
  click_button "Add User"
end

When /^I add a user with valid data$/ do
  visit 'users/'
  fill_in "Name", :with => "New User"
  fill_in "Email", :with => "anewuser@example.com"
  click_button "Add User"
end

When /^I delete a user$/ do
  fill_org_with_users
  visit "users/#{@user1.id}/edit"
  click_button 'Delete User'
end

When /^I change a user role to admin$/ do
  fill_org_with_users
  visit "users/#{@user1.id}/edit"
  select('ADMIN', :from => 'user_role')
  click_button "Update"
end

When /^I change a user role to user$/ do
  fill_org_with_users
  visit "users/#{@admin1.id}/edit"
  select('USER', :from => 'user_role')
  click_button "Update"
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Logout"
  page.should_not have_content "Sign up"
  page.should_not have_content "Login"
end

Then /^I should be signed out$/ do
  page.should have_content "Sign up"
  page.should have_content "Login"
  page.should_not have_content "Logout"
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content "You have to confirm your account before continuing."
end

Then /^I see a successful sign in message$/ do
  page.should have_content "Signed in successfully."
end

Then /^I should see a successful sign up message$/ do
  page.should have_content "You have signed up successfully."
end

Then /^I should see a missing name message$/ do
  page.should have_content "Name can't be blank"
end

Then /^I should see a missing organization name message$/ do
  page.should have_content "Organization name can't be blank"
end

Then /^I should see an invalid email message$/ do
  page.should have_content "Email is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "Password can't be blank"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "Password confirmation doesn't match"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "Password confirmation doesn't match"
end

Then /^I should see a signed out message$/ do
  page.should have_content "Signed out successfully."
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid email or password."
end

Then /^I should see an account edited message$/ do
  page.should have_content "You updated your account successfully."
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:name]
end

Then /^I should see a nonadmin message$/ do
  page.should have_content "You do not have administrative rights for this organization"
end

Then /^I should see a successful user addition message$/ do
  page.should have_content "User successfully added"
end

Then /^I should see the manage users page$/ do
  page.should have_content "Manage Users"
end

Then /^I should see a successful user deleted message$/ do
  page.should have_content "User successfully deleted"
end

Then /^I should see a successful user update message$/ do
  page.should have_content "User successfully updated"
end
