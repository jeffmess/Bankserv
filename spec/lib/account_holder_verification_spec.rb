require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  
  before(:each) do
    
  end
  
  it "should be able to queue a request for an account holder verification" do
    hash = {
      account_number: "2938423984",
      branch_code: "250255",
      id_number: '0394543905',
      initials: "P",
      surname: "Hendrik",
      user_ref: "34"
    }
    
    Bankserv::AccountHolderVerification.request(hash).should be_true
    
    Bankserv::AccountHolderVerification.unprocessed.count.should == 1
    last = Bankserv::AccountHolderVerification.unprocessed.last
    
    last.user_ref.should == "34"
  end
      
end