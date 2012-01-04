require 'spec_helper'

describe Bankserv::AccountHolderVerification do
  
  before(:each) do
    
  end
  
  it "should be able to queue a request for an account holder verification" do
    data = {
      account_number: "2938423984",
      branch_code: "250255",
      id_number: '0394543905',
      initials: "P",
      surname: "Hendrik",
      user_ref: "34"
    }
    
    hash = {
      type: 'ahv',
      data: data
    }
    
    Bankserv::AccountHolderVerification.request(hash).should be_true
    
    request = Bankserv::Request.last
    request.type.should == "ahv"
    request.data.should == data
  end
      
end
