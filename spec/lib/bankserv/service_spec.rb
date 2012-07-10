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
      transmission_number: "1",
      incoming_directory: "/tmp/1234/incoming",
      outgoing_directory: "/tmp/1234/outgoing",
      reply_directory: "/tmp/1234/incoming",
      archive_directory: "/tmp/1234/archive"
    }
    
    bankserv_service = Bankserv::AHVService.register(params)
    
    bankserv_service.is_a?(Bankserv::AHVService).should be_true
    bankserv_service.client_code.should == '1234'
    bankserv_service.config[:client_name].should == 'RCTEST'
    bankserv_service.config[:transmission_status].should == "L"
    bankserv_service.config[:transmission_number].should == "1"
    bankserv_service.config[:incoming_directory].should == "/tmp/1234/incoming"
    bankserv_service.config[:reply_directory].should == "/tmp/1234/incoming"
    bankserv_service.config[:outgoing_directory].should == "/tmp/1234/outgoing"
    bankserv_service.config[:archive_directory].should == "/tmp/1234/archive"
  end
  
end