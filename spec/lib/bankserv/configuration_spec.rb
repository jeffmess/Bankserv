require 'spec_helper'

describe Bankserv::Configuration do
  include Helpers
  
  before(:all) do 
    create(:configuration)
  end
  
  it "should store the client code" do
    Bankserv::Configuration.client_code.should == Bankserv::Configuration.active.client_code
  end
  
  it "should store the client name" do
    Bankserv::Configuration.client_name.should == Bankserv::Configuration.active.client_name
  end
  
  it "should store the user code" do
    Bankserv::Configuration.user_code.should == Bankserv::Configuration.active.user_code
  end
  
  it "should store the department code" do
    Bankserv::Configuration.department_code.should == Bankserv::Configuration.active.department_code
  end
  
end