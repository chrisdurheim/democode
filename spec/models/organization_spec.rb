require 'spec_helper'

describe Organization do

  it "should create a new instance given a valid attribute" do
    create(:organization).should be_valid
  end

  it "should require a name" do
    build(:organization, name: nil).should_not be_valid
  end

  it "should respond to users" do
    create(:organization).should respond_to(:users)
  end
end
