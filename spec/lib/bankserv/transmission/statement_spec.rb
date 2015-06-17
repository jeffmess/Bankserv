require 'spec_helper'

describe Bankserv::Statement do
  include Helpers
  
  before(:each) do
    tear_it_down
    Bankserv::StatementService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

    @file_contents = File.open("./spec/examples/statement4_unpacked.dat", "rb").read
    @statement = Bankserv::Statement.store(@file_contents)
  end
  
  context "storing a statement" do
    
    it "should store the client code" do
      @statement.client_code.should == "3174"
    end
    
    it "should mark the statement as unprocessed" do
      @statement.processed.should be_false
    end
    
    it "should store the hash of information returned from the absa-esd gem as the statement's serialized data" do
      @statement.data.should == Absa::Esd::Transmission::Document.hash_from_s(@file_contents)
    end
    
  end
  
  context "storing a blank document" do
    
    before(:each) do
      Bankserv::StatementService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

      @blank_file_contents = File.open("./spec/examples/blank_statement.dat", "rb").read
      @blank_statement = Bankserv::Statement.store(@blank_file_contents)
    end
    
    it "should store the file" do
      @blank_statement.client_code.should == "10831"
    end
    
    it "should not store any transactions when processed" do
      @blank_statement.process!
      Bankserv::Transaction.all.should be_blank
      @blank_statement.should be_processed
    end
    
  end
  
  context "processing a statement" do
    
    before(:each) do
      @statement.process!
    end
    
    it "should create a transaction for each recon account detail record" do
      @statement.transactions.count.should == 46
      
      Bankserv::Transaction.all.each do |t|
        t.statement.should == @statement
      end
    end
    
    it "should set each transaction's client code to the statement's client code" do
      @statement.transactions.all?{|t| t.client_code == "3174"}
    end
    
    it "should default the transactions to unprocessed" do
      @statement.transactions.all?{|t| t.processed == false}
    end
    
    it "should store the recon account detail record's data as the transaction's data" do
      @statement.transactions.first.data.should == {
        rec_type: "2", 
        account_number: "4011111809", 
        statement_number: "264", 
        page_number: "1", 
        transaction_processing_date: "20021118", 
        transaction_effective_date: "20021118", 
        cheque_number: "0", 
        transaction_reference_number: "103899", 
        transaction_amount_sign: "+", 
        transaction_amount: "2630670", 
        account_balance_sign: "+", 
        account_balance_after_transaction: "2630670", 
        transaction_description: "ACB CREDIT           SETTLEMENT", 
        dep_id: "BASGHW    GP HEALTH000212608", 
        transaction_code: "FN71", 
        cheques_function_code: "ACC", 
        charge_levied_amount_sign: "+", 
        charge_levied_amount: "0", 
        charge_type: "", 
        stamp_duty_amount_sign: "+", 
        stamp_duty_levied_amount: "0", 
        cash_deposit_fee_sign: "+", 
        cash_deposit_fee: "0", 
        charges_accrued: "", 
        event_number: "12533", 
        statement_line_sequence_number: "4", 
        vat_amount: "0", 
        cash_portion: "0", 
        deposit_number: "0", 
        transaction_time: "0", 
        filler_1: "", 
        filler_2: "", 
        sitename: "", 
        category: "0012", 
        transaction_type: "", 
        deposit_id_description: "", 
        pod_adjustment_amount: "000000000000000", 
        pod_adjustment_reason: "", 
        pod_returned_cheque_reason_code: "0", 
        pod_returned_cheque_drawee: "", 
        fedi_payor: "", 
        fedi_number: "0", 
        redirect_description: "", 
        account_number_redirect: "0", 
        unpaid_cheque_reason_description: "", 
        filler_3: "", 
        generation_number: "000000295", 
        old_reconfocus_category1: "51", 
        old_reconfocus_category2: "51", 
        filler_4: ""
      }
    end
    
  end
  
  context "processing a statement with multiple accounts and checking the transaction count" do
    
    before(:each) do
      tear_it_down
      Bankserv::StatementService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

      @file_contents = File.open("./spec/examples/statement-with-multiple-accounts.dat", "rb").read
      @statement = Bankserv::Statement.store(@file_contents)
      @statement.process!
    end

    it 'should check transaction count by account number for ACC: 4079323853' do
      transactions = @statement.transactions.select do |transaction|
        transaction.data[:account_number] == '4079323853'
      end
      
      count = 1

      transactions.each do |t| 
        t.data[:transaction_number_for_day].should == count
        count += 1
      end
    end

    it 'should check transaction count by account number for ACC: 4083387742' do
      transactions = @statement.transactions.select do |transaction|
        transaction.data[:account_number] == '4083387742'
      end
      
      count = 1

      transactions.each do |t| 
        t.data[:transaction_number_for_day].should == count
        count += 1
      end
    end
  end  
end