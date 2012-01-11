require 'spec_helper'

describe Bankserv::Transmission::UserSet::Debit do
  include Helpers
  
  context "Building a debit batch" do
    
    before(:all) do
      tear_it_down
      
      @data = [{
         credit: {
           account_number: "907654321", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 1000000, user_ref: 234, action_date: Date.today },
         debit: [
           { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "235"},
           { account_number: "45645645645", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "236"},
           { account_number: "78978978978", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 250000, action_date: Date.today, user_ref: "237"}
         ]
       }, {
         credit: {
           account_number: "907654322", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 1500000, user_ref: 300, action_date: Date.today },
         debit: [
           { account_number: "13123123122", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "301"},
           { account_number: "45645645642", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "302"},
           { account_number: "78978978972", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 750000, action_date: Date.today, user_ref: "303"}
         ]
       }]

       @hash = {
         type: 'debit',
         data: @data
       }
      
       Bankserv::Debit.request(@hash)
    end
    
    it "should return true when a batch needs to be processed" do
      Bankserv::Transmission::UserSet::Debit.has_work?.should be_true
    end 
    
    it "should create a batch with a header when the job begins" do
      batch = Bankserv::Transmission::UserSet::Debit.generate
      batch.save
      
      purge = (Date.today + 7.days).strftime("%y%m%d")
      
      batch.header.data.should == {
        rec_id: "001",
        rec_status: "T",
        bankserv_record_identifier: "04",
        bankserv_user_code: "RC UC",
        bankserv_creation_date: Time.now.strftime("%y%m%d"),
        bankserv_purge_date: purge,
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        first_sequence_number: "1",
        user_generation_number: "2",
        type_of_service: "SAMEDAY",
        accepted_report: "",
        account_type_correct: ""
      }
    end
    
    it "should create a 2 batches of debit transactions when the job begins" do
      batch = Bankserv::Transmission::UserSet::Debit.generate
      batch.save
      
      batch.contra_records.size.should == 2
    end
    
    it "should create a batch with a trailer when the job begins" do
      batch = Bankserv::Transmission::UserSet::Debit.generate
      batch.save
      
      batch.trailer.data.should == {
        rec_id: "001",
        rec_status: "T",
        bankserv_record_identifier: "92",
        bankserv_user_code: "RC UC",
        first_sequence_number: 1,
        last_sequence_number: 8,
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        no_debit_records: 8,
        no_credit_records: 0,
        no_contra_records: 0,
        total_debit_value: 5000000,
        total_credit_value: 0,
        hash_total_of_homing_account_numbers: 277310804125,
        user_generation_number: "2",
        type_of_service: "SAMEDAY"
      }
    end
  end
      
end
