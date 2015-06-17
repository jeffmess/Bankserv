require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  include Helpers
  
  before(:each) do    
    tear_it_down
    
    @ahv_service = Bankserv::AHVService.register(client_code: 12345, internal_branch_code: '632005', transmission_status: "L", transmission_number: "1")
       
    @hash = attributes_for(:ahv_bankserv_request)
    @hash[:data][:bank_account] = attributes_for(:bank_account)
  end
  
  context "requesting an account holder verification" do
  
    it "should be able to queue a request for an account holder verification" do
      @ahv_service.request(@hash).should be_truthy
    
      request = Bankserv::Request.last
      request.type.should == "ahv"
      request.data.should == @hash[:data]
    end
    
    it "should work" do
      b_a = {
        :account_number=>"2938423984",
        :id_number=>"0394543905",
        :initials=>"P",
        :account_name=>"Hendrik",
        :branch_code=>"250255",
        :account_type=>"savings"
      }
      
      info = {data: {user_ref: 83745678, bank_account: b_a}}
      Bankserv::AHVService.last.request(info)
    end
          
  end
  
  context "when creating a new account holder verification" do
    
    it "should be marked as new" do
      @ahv_service.request(@hash)
      Bankserv::AccountHolderVerification.last.new?.should be_truthy
    end
  
    it "should create an account holder verification record, with associated bank account" do
      @ahv_service.request(@hash).should be_truthy
    
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.new?.should be_truthy
  
      @hash[:data][:bank_account].each{|k,v| ahv.bank_account.send(k).should == v}
    end
  
    it "should mark verifications with an absa branch code as internal" do
      @hash[:data][:bank_account].merge!(attributes_for(:internal_bank_account))
      @ahv_service.request(@hash).should be_truthy
      
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.should be_internal
    end
  
    it "should mark verifications with a non-absa branch code as external" do
      @hash[:data][:bank_account].merge!(attributes_for(:external_bank_account))
      @ahv_service.request(@hash).should be_truthy
    
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.should be_external
    end
    
  end
  
  context "when processing an account holder verification response" do
    
    before(:all) do
      @ahv = create(:ahv)
      @response = {:return_code_1 => "0", :return_code_2 => "0", :return_code_3 => "0", :return_code_4 => "0"}
    end
    
    it "should be marked as completed" do
      @ahv.process_response(@response)
      @ahv.completed?.should be_truthy
    end
    
    it "should record whether the account number matched" do
      @ahv.process_response(@response)
      
      @ahv.response[:account_number].should be(:match)
    end
    
    it "should record whether the id number matched" do
      @ahv.process_response(@response)
      
      @ahv.response[:id_number].should be(:match)
    end
    
    it "should record whether the initials matched" do
      @ahv.process_response(@response)
      
      @ahv.response[:initials].should be(:match)
    end
    
    it "should record whether the surname matched" do
      @ahv.process_response(@response)
      
      @ahv.response[:surname].should be(:match)
    end
    
  end
  
      
end
