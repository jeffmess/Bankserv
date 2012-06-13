require 'spec_helper'

describe Bankserv::NotifyMeStatement do
  include Helpers
  
  before(:each) do
    tear_it_down
    Bankserv::NotifyMeStatementService.register(client_code: '09876', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

    @file_contents = File.open("./spec/examples/notify_me.xml", "rb").read
    @statement = Bankserv::NotifyMeStatement.store(@file_contents)
  end
  
  context "storing a statement" do
    
    it "should store the client code" do
      @statement.client_code.should == "09876"
    end
    
    it "should mark the statement as unprocessed" do
      @statement.processed.should be_false
    end
    
    it "should store the hash of information returned from the absa-notify-me gem as the statement's serialized data" do
      @statement.data.should == Absa::NotifyMe::XmlStatement.string_to_hash(@file_contents)
    end
    
  end
  
  context "processing a statement" do
    
    before(:each) do
      @statement.process!
    end
    
    it "should contain the same amount of transactions that the trailer specifies" do
      @statement.notify_me_transactions.count.should == @statement.data[:data][:data].last[:data][:total_recs].to_i
    end
    
    it "should create a transaction for each recon account detail record" do
      Bankserv::NotifyMeTransaction.all.each do |t|
        t.notify_me_statement.should == @statement
      end
    end
    
    it "should set each transaction's client code to the statement's client code" do
      @statement.notify_me_transactions.all?{|t| t.client_code == "09876"}
    end
    
    it "should default the transactions to unprocessed" do
      @statement.notify_me_transactions.all?{|t| t.processed == false}
    end
    
    it "should store the recon account detail record's data as the notify_me_transaction's data" do
      @statement.notify_me_transactions.first.data.should == {
        account_number: "170000072",
        event_number: "032537937",
        customer_reference: "DEP NO :          81557294",
        currency: "ZAR",
        amount: "5005",
        account_balance_after_transaction: "8900743687",
        transaction_type: "C",
        transaction_processing_date: "20110509",
        clearance_payment_indicator: "N",
        transaction_description: "CASH DEP BRANCH",
        checksum: "F6AA9A0C43A6F429DECE136893283B5A"
      }
    end
    
  end
  
end