require 'spec_helper'

describe Bankserv::Service do
  include Helpers
  
  before(:each) do
    tear_it_down
  end
  
  it "should allow a service to be registered" do
    params = {
      service_type: 'ahv',
      client_code: '1234',
      client_name: 'RCTEST',
      transmission_status: "L",
      transmission_number: "1"
    }
    
    response = Bankserv::Service.register(params)
    
    response.should == Bankserv::Service.last.id
    
    config = Bankserv::Service.find(response)
    config.type.should == 'ahv'
    config.client_code.should == '1234'
    config.config[:client_name].should == 'RCTEST'
    config.config[:transmission_status].should == "L"
    config.config[:transmission_number].should == "1"
  end
  
end