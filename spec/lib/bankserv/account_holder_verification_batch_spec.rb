require 'spec_helper'

describe Bankserv::AccountHolderVerificationBatch do
  
  context "Building an account holder verification batch" do
    
    before(:all) do
      @bank_hash = {
        account_number: "2938423984",
        branch_code: "250255",
        account_type: 'savings',
        id_number: '0394543905',
        initials: "P",
        account_name: "Hendrik"
      }
    
      @hash = {
        type: 'ahv',
        data: {user_ref: "34"}.merge(@bank_hash)
      }
      Bankserv::AccountHolderVerification.request(@hash)
    end
    
    it "should return true when a batch needs to be processed" do
      Bankserv::AccountHolderVerificationBatch.has_work?.should be_true
    end 
  
    # it "should be able to queue a request for an account holder verification" do
    #   Bankserv::AccountHolderVerification.request(@hash).should be_true
    # 
    #   request = Bankserv::Request.last
    #   request.type.should == "ahv"
    #   request.data.should == @hash[:data]
    # end
    # 
    # it "should create an account holder verification record, with associated bank account" do
    #   Bankserv::AccountHolderVerification.request(@hash).should be_true
    #   
    #   ahv = Bankserv::AccountHolderVerification.for_reference(@hash[:data][:user_ref]).first
    #   ahv.processed.should be_false
    # 
    #   @bank_hash.each{|k,v| ahv.bank_account.send(k).should == v}
    # end
  
  end
      
end
