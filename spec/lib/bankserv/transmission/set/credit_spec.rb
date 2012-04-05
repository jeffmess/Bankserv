require 'spec_helper'

describe Bankserv::Transmission::UserSet::Credit do
  include Helpers
  
  context "Building a credit batch" do
    
    before(:all) do
      tear_it_down
      
      create(:configuration, client_code: "10", client_name: "LDC USER 10 AFRICA (PTY)", user_code: "9534", user_generation_number: 37, client_abbreviated_name: "ALIMITTST")
      
      @data = [{
         debit: {
           account_number: "907654321", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 1000000, user_ref: 234, action_date: Date.today },
         credit: [
           { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "235"},
           { account_number: "45645645645", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "236"},
           { account_number: "78978978978", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 250000, action_date: Date.today, user_ref: "237"}
         ]
       }, {
         debit: {
           account_number: "907654322", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 1500000, user_ref: 300, action_date: Date.today },
         credit: [
           { account_number: "13123123122", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "301"},
           { account_number: "45645645642", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "302"},
           { account_number: "78978978972", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 750000, action_date: Date.today, user_ref: "303"}
         ]
       }]

       @hash = {
         type: 'credit',
         data: { type_of_service: "SAMEDAY", batches: @data }
       }
      
       Bankserv::Credit.test_request(@hash)
    end
    
    it "should return true when a batch needs to be processed" do
      Bankserv::Transmission::UserSet::Credit.has_test_work?.should be_true
    end 
    
    it "should create a batch with a header when the job begins" do
      batch = Bankserv::Transmission::UserSet::Credit.generate(rec_status: "T")
      batch.save
      
      purge = (Date.today + 7.days).strftime("%y%m%d")
      
      batch.header.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "04",
        bankserv_user_code: "9534",
        bankserv_creation_date: Time.now.strftime("%y%m%d"),
        bankserv_purge_date: purge,
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: (Date.today + 3.days).strftime("%y%m%d"),
        first_sequence_number: "1",
        user_generation_number: "37",
        type_of_service: "SAMEDAY",
        accepted_report: "",
        account_type_correct: ""
      }
    end
    
    it "should create a 2 batches of debit transactions when the job begins" do
      batch = Bankserv::Transmission::UserSet::Credit.generate(rec_status: "T")
      batch.save
      
      batch.contra_records.size.should == 2
    end
    
    it "should create a batch with a trailer when the job begins" do
      batch = Bankserv::Transmission::UserSet::Credit.generate(rec_status: "T")
      batch.save
      
      batch.trailer.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "92",
        bankserv_user_code: "9534",
        first_sequence_number: "1",
        last_sequence_number: "8",
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: (Date.today + 3.days).strftime("%y%m%d"),
        no_debit_records: "2",
        no_credit_records: "6",
        no_contra_records: "2",
        total_debit_value: "2500000",
        total_credit_value: "2500000",
        hash_total_of_homing_account_numbers: "277310804125"
      }
    end
  end
      
end
