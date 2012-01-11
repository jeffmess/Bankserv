require 'spec_helper'

describe Bankserv::Configuration do
  include Helpers
  
  before(:all) do 
    Bankserv::Configuration.create! active: true, client_code: "234234", client_name: "RENTCONN", user_code: "054324", department_code: "A12345"
  end
  
  it "should store the client code" do
    Bankserv::Configuration.client_code.should == "234234"
  end
  
  it "should store the client name" do
    Bankserv::Configuration.client_name.should == "RENTCONN"
  end
  
  it "should store the user code" do
    Bankserv::Configuration.user_code.should == "054324"
  end
  
  it "should store the department code" do
    Bankserv::Configuration.department_code.should == "A12345"
  end
  
end