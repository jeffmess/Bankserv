require 'spec_helper'

describe Bankserv::Document do
  include Helpers
  
  context "building a transmission document containing two account holder verification requests" do
  
    before(:all) do
      tear_it_down
      create(:configuration)
    
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "1094402524",
          branch_code: "250255",
          account_type: 'savings',
          id_number: '6703085829086',
          initials: "M",
          account_name: "CHAUKE"
        ),
        user_ref: "149505000060000223600000000000",
        internal: true
      )
    
      ahv.save!
    
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2968474669",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '6103120039082',
          initials: "A",
          account_name: "VAN MOLENDORF"
        ),
        user_ref: "198841000060000223600000000000",
        internal: true
      )
    
      ahv.save!
      
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2492008177",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '8801261110087',
          initials: "U",
          account_name: "NKWEBA"
        ),
        user_ref: "149205000060000223600000000000",
        internal: true
      )
    
      ahv.save!
      
      Bankserv::Configuration.should_receive(:department_code).and_return("000001")
      t = Time.local(2009, 7, 3, 10, 5, 0)
      Timecop.travel(t)
      
      Bankserv::Configuration.stub!(:reserve_user_generation_number!).and_return("1")
    
      Bankserv::Document.generate!(
        mode: "L", 
        client_code: "2236", 
        client_name: "TEST", 
        transmission_no: "0", 
        th_for_use_of_ld_user: ""
      )
      
      @document = Bankserv::Document.last
    end
    
    it "should mark the document as an input transmission" do
      @document.type.should == "input"
    end
  
    it "should build a new document" do
      hash = @document.to_hash
      
      string = File.open("./spec/examples/ahv_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options
    end
  end
  
  context "building a transmission document two batches of debit order requests" do
    before(:all) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::AccountHolderVerification.delete_all
      Bankserv::Debit.delete_all
      
      tear_it_down      
      create(:configuration, client_code: "10", client_name: "LDC USER 10 AFRICA (PTY)", user_code: "9534", user_generation_number: 37, client_abbreviated_name: "ALIMITTST")
      
      t = Time.local(2004, 5, 24, 10, 5, 0)
      Timecop.travel(t)
      
      debit = Bankserv::Debit.request({
        type: 'debit',
        data: {
          type_of_service: "CORPSSV",
          batches: [{
            credit: {
              account_number: "4053538939", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 16028000, user_ref: "1CONTRA 040524 08", action_date: Date.today
            },
            debit: [
              { account_number: '1019611899', branch_code: "632005", account_type: "1", id_number: '', amount: 1000,    action_date: Date.today, account_name: "HENNIE DU TOIT",  user_ref: '1SPP    040524 01'},
              { account_number: '1019801892', branch_code: "632005", account_type: "1", id_number: '', amount: 2000,    action_date: Date.today, account_name: "TYRONE DREYDEN",  user_ref: "1SPP    040524 02"},
              { account_number: '1021131896', branch_code: "632005", account_type: "1", id_number: '', amount: 3000,    action_date: Date.today, account_name: "KEITH MEIKLEJOHN",user_ref: "1SPP    040524 03"},
              { account_number: '1022131890', branch_code: "632005", account_type: "1", id_number: '', amount: 4000,    action_date: Date.today, account_name: "CHRISTO SPIES",   user_ref: "1SPP    040524 04"},
              { account_number: '1057401890', branch_code: "632005", account_type: "1", id_number: '', amount: 6005000, action_date: Date.today, account_name: "DENISE RETIEF",   user_ref: "1SPP    040524 05"}, 
              { account_number: '18000010304',branch_code: "632005", account_type: "1", id_number: '', amount: 3006000, action_date: Date.today, account_name: "PETER HAUPT",     user_ref: "1SPP    040524 06"},  
              { account_number: '1020861726', branch_code: "632005", account_type: "1", id_number: '', amount: 7007000, action_date: Date.today, account_name: "HADLEY RAW",      user_ref: "1SPP    040524 07"}    
            ]
          }, {
            credit: {
              account_number: "1004651894", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 4280000, user_ref: "2CONTRA 040525 08", action_date: Date.tomorrow
            },
            debit: [
              { account_number: '1006221897', branch_code: "632005", account_type: "1", id_number: '', amount: 10000,  action_date: Date.tomorrow, account_name: "HENNIE DU TOIT",  user_ref: '2SPP    040525 01'},
              { account_number: '1006241898', branch_code: "632005", account_type: "1", id_number: '', amount: 20000,  action_date: Date.tomorrow, account_name: "TYRONE DREYDEN",  user_ref: "2SPP    040525 02"},
              { account_number: '1009831891', branch_code: "632005", account_type: "1", id_number: '', amount: 4030000,action_date: Date.tomorrow, account_name: "KEITH MEIKLEJOHN",user_ref: "2SPP    040525 03"},
              { account_number: '1010000609', branch_code: "632005", account_type: "1", id_number: '', amount: 40000,  action_date: Date.tomorrow, account_name: "CHRISTO SPIES",   user_ref: "2SPP    040525 04"},
              { account_number: '1019141892', branch_code: "632005", account_type: "1", id_number: '', amount: 50000,  action_date: Date.tomorrow, account_name: "DENISE RETIEF",   user_ref: "2SPP    040525 05"}, 
              { account_number: '1019591898', branch_code: "632005", account_type: "1", id_number: '', amount: 60000,  action_date: Date.tomorrow, account_name: "PETER HAUPT",     user_ref: "2SPP    040525 06"},  
              { account_number: '1020861726', branch_code: "632005", account_type: "1", id_number: '', amount: 70000,  action_date: Date.tomorrow, account_name: "HADLEY RAW",      user_ref: "2SPP    040525 07"}
            ]
          }]
        }
      })
    end
    
    it "should build a new document with debit sets and a header" do  
      Bankserv::Document.generate!(
        mode: "T", 
        transmission_no: "621", 
        th_for_use_of_ld_user: ""
      )
      
      document = Bankserv::Document.last
      hash = document.to_hash
      
      string = File.open("./spec/examples/debit_eft_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options
    end
  
  end
  
  context "storing an output transmission containing an account holder verification set" do
    
    before(:all) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/ahv_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @document = Bankserv::Document.store_output_document(@file_contents)
    end
    
    it "should mark the document as an output transmission" do
      @document.type.should == "output"
    end
    
    it "should store a document, set and records that produce the same data as was provided" do
      @document.to_hash.should == @options
    end
    
    it "should produce the exact same file contents when the transmission is rebuilt" do
      absa_document = Absa::H2h::Transmission::Document.build(@document.to_hash[:data])
      absa_document.to_s.should == @file_contents
    end
    
    it "should be able to process the document, updating any related account holder verifications" do
      ahv1 = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "1094402524",
          branch_code: "250255",
          account_type: 'savings',
          id_number: '6703085829086',
          initials: "M",
          account_name: "CHAUKE"
        ),
        user_ref: "149505000000000223600000008000",
        internal: true
      )
    
      ahv1.save!
    
      ahv2 = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2968474669",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '6103120039082',
          initials: "A",
          account_name: "VAN MOLENDORF"
        ),
        user_ref: "198841000000000223600000000000",
        internal: true
      )
    
      ahv2.save!
      
      ahv3 = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2492008177",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '8801261110087',
          initials: "U",
          account_name: "NKWEBA"
        ),
        user_ref: "149205000000000223605000700000",
        internal: true
      )
    
      ahv3.save!
      
      Bankserv::AccountHolderVerification.for_reference("149505000000000223600000008000").first.completed?.should be_false
      Bankserv::AccountHolderVerification.for_reference("198841000000000223600000000000").first.completed?.should be_false
      Bankserv::AccountHolderVerification.for_reference("149205000000000223605000700000").first.completed?.should be_false
      
      Bankserv::Document.process_output_document(@document)
      
      Bankserv::AccountHolderVerification.for_reference("149505000000000223600000008000").first.completed?.should be_true
      Bankserv::AccountHolderVerification.for_reference("198841000000000223600000000000").first.completed?.should be_true
      Bankserv::AccountHolderVerification.for_reference("149205000000000223605000700000").first.completed?.should be_true
    end
    
  end
  
  context "storing an output transmission containing an eft set" do

     before(:all) do
       tear_it_down
       create(:configuration)

       @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
       @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
       
       #puts @options.inspect

       @document = Bankserv::Document.store_output_document(@file_contents)
     end

     it "should mark the document as an output transmission" do
       @document.type.should == "output"
     end

   end
  
   
end
