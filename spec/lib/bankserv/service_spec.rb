require 'spec_helper'

describe Bankserv::Service do
  include Helpers
  
  before(:each) do
    tear_it_down
  end
  
  it "should allow a service to be registered" do
    params = {
      client_code: '1234',
      client_name: 'RCTEST',
      transmission_status: "L",
      transmission_number: "1"
    }
    
    bankserv_service = Bankserv::AHVService.register(params)
    
    bankserv_service.is_a?(Bankserv::AHVService).should be_true
    bankserv_service.client_code.should == '1234'
    bankserv_service.config[:client_name].should == 'RCTEST'
    bankserv_service.config[:transmission_status].should == "L"
    bankserv_service.config[:transmission_number].should == "1"
  end
  
end