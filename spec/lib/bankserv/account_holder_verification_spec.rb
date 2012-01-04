require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  
  before(:each) do
    
  end
  
  it "should be able to queue a request for an account holder verification" do
    bank_hash = {
      account_number: "2938423984",
      branch_code: "250255",
      account_type: 'savings',
      id_number: '0394543905',
      initials: "P",
      account_name: "Hendrik"
    }
    
    hash = {
      type: 'ahv',
      data: {user_ref: "34"}.merge(bank_hash)
    }
    
    Bankserv::AccountHolderVerification.request(hash).should be_true
    
    request = Bankserv::Request.last
    request.type.should == "ahv"
    request.data.should == hash[:data]
    
    ahv = Bankserv::AccountHolderVerification.for_reference(hash[:data][:user_ref]).first
    ahv.processed.should be_false
    
    bank_hash.each do |k,v|
      ahv.bank_account.send(k).should == v
    end
    
  end
      
end
