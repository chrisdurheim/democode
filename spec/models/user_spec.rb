require 'spec_helper'

describe User do

  it "has a valid factory" do
    create(:user).should be_valid
  end

  it "responds to organization" do
    valid_user = create(:user)
    valid_user.should respond_to(:organization)
  end

  it "creates a new instance given a valid attribute" do
    build(:user).should be_valid
  end

  it "is invalid without a name" do
    build(:user, name: nil).should_not be_valid
  end

  it "is invalid without a corresponding organization" do
    build(:user, organization: nil).should_not be_valid
  end

  it "is invalid without an email address" do
    build(:user, email: nil).should_not be_valid
  end

  it "accepts valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = build(:user, :email => address)
      valid_email_user.should be_valid
    end
  end

  it "rejects invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = build(:user, :email => address)
      invalid_email_user.should_not be_valid
    end
  end

  it "rejects duplicate email addresses" do
    create(:user, :email => "duplicate@example.com")
    user_with_duplicate_email = build(:user, :email => "duplicate@example.com")
    user_with_duplicate_email.should_not be_valid
  end

  it "rejects email addresses identical up to case" do
    create(:user, :email => "DuPlIcAtE@ExAmPlE.cOm")
    user_with_duplicate_email = build(:user, :email => "dUpLiCaTe@eXaMpLe.CoM")
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = create(:user)
    end

    it "has a password attribute" do
      @user.should respond_to(:password)
    end

    it "has a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "requires a password" do
      build(:user, :password => "", :password_confirmation => "").should_not be_valid
    end

    it "requires a matching password confirmation" do
      build(:user, :password_confirmation => "nonmatching").should_not be_valid
    end

    it "rejects short passwords" do
      short = "a" * 5
      build(:user, :password => short, :password_confirmation=> "short").should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = create(:user)
    end

    it "has an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "sets the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

  end

  describe "role" do
    it "only allows valid roles" do
      fake_roles = ["ROCKSTAR", ""]
      fake_roles.each do |fake_role|
        build(:user, role: fake_role).should_not be_valid
      end
    end

    it "forces role to user if blank" do
      create(:user, role: nil).role.should eq("USER")
    end

    it "responds to admin?" do
      create(:user).should respond_to(:admin?)
    end

    it "responds true to admin? for admins" do
      create(:admin).admin?.should be_true
    end

    it "responds false to admin? for non-admins" do
      create(:user).admin?.should_not be_true
    end
  end

end
