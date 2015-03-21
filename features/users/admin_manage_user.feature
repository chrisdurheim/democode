Feature: Admin Manage User
  In order to allow my employees to use the tool
  As an Admin
  I want to be able to manage users to my organization

    Scenario: User is not an admin, views add user page
      Given I do not exist as an organization admin
      When I sign in with valid admin credentials
      And I go to add a user to my organization
      Then I should see a nonadmin message

    Scenario: User is an admin, views add user page
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I go to add a user to my organization
      Then I should see the manage users page

    Scenario: User is an admin, adds user with no name
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I add a user with no name
      Then I should see a missing name message

    Scenario: User is an admin, adds user with invalid email
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I add a user with invalid email
      Then I should see an invalid email message

    Scenario: User is an admin, adds user with valid data
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I add a user with valid data
      Then I should see a successful user addition message

    Scenario: User is an admin, deletes other user
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I delete a user
      Then I should see a successful user deleted message

    Scenario: User is an admin, changes user to admin
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I change a user role to admin
      Then I should see a successful user update message

    Scenario: User is an admin, changes admin to user
      Given I exist as an organization admin
      When I sign in with valid admin credentials
      And I change a user role to user
      Then I should see a successful user update message
