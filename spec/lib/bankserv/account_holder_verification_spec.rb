require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  include Helpers
  
  context "requesting an account holder verification" do
    
    before(:each) do    
      tear_it_down
         
      @hash = attributes_for(:ahv_bankserv_request)
      @hash[:data][:bank_account] = attributes_for(:bank_account)
    end
  
    it "should be able to queue a request for an account holder verification" do
      Bankserv::AccountHolderVerification.request(@hash).should be_true
    
      request = Bankserv::Request.last
      request.type.should == "ahv"
      request.data.should == @hash[:data]
    end
    
    context "when creating a new account holder verification" do
    
      it "should create an account holder verification record, with associated bank account" do
        Bankserv::AccountHolderVerification.request(@hash).should be_true
      
        ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
        ahv.processed.should be_false
    
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
      
    end
  
  end
      
end
