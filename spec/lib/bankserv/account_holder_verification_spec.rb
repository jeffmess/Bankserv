require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  include Helpers
  
  before(:each) do    
    tear_it_down
    create(:configuration)
       
    @hash = attributes_for(:ahv_bankserv_request)
    @hash[:data][:bank_account] = attributes_for(:bank_account)
  end
  
  context "requesting an account holder verification" do
  
    it "should be able to queue a request for an account holder verification" do
      Bankserv::AccountHolderVerification.test_request(@hash).should be_true
    
      request = Bankserv::Request.last
      request.type.should == "ahv"
      request.data.should == @hash[:data]
    end
          
  end
  
  context "when creating a new account holder verification" do
    
    it "should be marked as new" do
      Bankserv::AccountHolderVerification.request(@hash)
      Bankserv::AccountHolderVerification.last.new?.should be_true
    end
  
    it "should create an account holder verification record, with associated bank account" do
      Bankserv::AccountHolderVerification.request(@hash).should be_true
    
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.new?.should be_true
  
      @hash[:data][:bank_account].each{|k,v| ahv.bank_account.send(k).should == v}
    end
  
    it "should mark verifications with an absa branch code as internal" do
      @hash[:data][:bank_account].merge!(attributes_for(:internal_bank_account))
      Bankserv::AccountHolderVerification.request(@hash).should be_true
      
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.should be_internal
    end
  
    it "should mark verifications with a non-absa branch code as external" do
      @hash[:data][:bank_account].merge!(attributes_for(:external_bank_account))
      Bankserv::AccountHolderVerification.request(@hash).should be_true
    
      ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
      ahv.should be_external
    end
    
    it "should generate a unique internal reference" do
      Bankserv::AccountHolderVerification.request(@hash)
      Bankserv::AccountHolderVerification.last.internal_user_ref.should match /AHV[0-9]+/
    end
    
  end
  
  context "when processing an account holder verification response" do
    
    before(:all) do
      @ahv = create(:ahv)
      @response = {:return_code_1 => "0", :return_code_2 => "0", :return_code_3 => "0", :return_code_4 => "0"}
    end
    
    it "should be marked as completed" do
      @ahv.process_response(@response)
      @ahv.completed?.should be_true
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
