require 'spec_helper'

describe Bankserv::Transaction do
  include Helpers
  
  before(:each) do
    tear_it_down
  end
  
  it "should default the transaction to unprocessed when it is created" do
    Bankserv::Transaction.create!
    
    Bankserv::Transaction.last.processed.should == false
  end
  
  it "should retrieve all unprocessed records" do
    Bankserv::Transaction.create! data: {}, client_code: "1"
    Bankserv::Transaction.create! data: {}, client_code: "2", processed: true
    Bankserv::Transaction.create! data: {}, client_code: "3"
    
    Bankserv::Transaction.unprocessed.count.should == 2
  end
  
  it "should retrieve records by client code" do
    transactions = 3.times.map do |i|
      Bankserv::Transaction.create! data: {}, client_code: "345#{i}"
    end
    
    Bankserv::Transaction.for_client_code("3451").count.should == 1
  end
  
end