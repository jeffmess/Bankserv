require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  
  context "requesting an account holder verification" do
    
    before(:all) do
      @bank_hash = {
        account_number: "2938423984",
        branch_code: "632005",
        account_type: 'savings',
        id_number: '0394543905',
        initials: "P",
        account_name: "Hendrik"
      }
    
      @hash = {
        type: 'ahv',
        data: {user_ref: "34"}.merge(@bank_hash)
      }
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
    
        @bank_hash.each{|k,v| ahv.bank_account.send(k).should == v}
      end
    
      it "should mark verifications with an absa branch code as internal" do
        Bankserv::AccountHolderVerification.request(@hash).should be_true
        
        ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
        ahv.should be_internal
      end
    
      it "should mark verifications with a non-absa branch code as external" do
        @hash[:data][:branch_code] = "250255"
        
        Bankserv::AccountHolderVerification.request(@hash).should be_true
      
        ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
        ahv.should be_external
      end
      
    end
  
  end
      
end
