require 'spec_helper'

describe Bankserv::Transmission::UserSet::Credit do
  include Helpers
  
  context "Building a credit batch" do
    
    before(:each) do
      tear_it_down
      
      bankserv_service = Bankserv::CreditService.register(client_code: '10', client_name: "LDC USER 10 AFRICA (PTY)", client_abbreviated_name: 'ALIMITTST', user_code: "9534", generation_number: 37, transmission_status: "T", transmission_number: "1")
      debit_service = Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 37, transmission_status: "L", transmission_number: "1")
      
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

      bankserv_service.request(@hash)
      @batches = Bankserv::Transmission::UserSet::Credit.generate(rec_status: "T")
      @batches.each {|x| x.save!}
    end
    
    it "should return true when a set needs to be processed" do
      Bankserv::Transmission::UserSet::Credit.has_test_work?.should be_true
    end 
    
    it "should create 2 sets with a header when the job begins" do

      @batches.first.header.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "04",
        bankserv_user_code: "9534",
        bankserv_creation_date: Time.now.strftime("%y%m%d"),
        bankserv_purge_date: Time.now.strftime("%y%m%d"),
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        first_sequence_number: "1",
        user_generation_number: "37",
        type_of_service: "SAMEDAY",
        accepted_report: "Y",
        account_type_correct: "Y"
      }

      @batches.second.header.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "04",
        bankserv_user_code: "9534",
        bankserv_creation_date: Time.now.strftime("%y%m%d"),
        bankserv_purge_date: Time.now.strftime("%y%m%d"),
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        first_sequence_number: "5",
        user_generation_number: "38",
        type_of_service: "SAMEDAY",
        accepted_report: "Y",
        account_type_correct: "Y"
      }

    end
    
    it "should create a contra record for each set" do
      @batches.each do |batch|
        batch.contra_records.size.should == 1
      end
    end
    
    it "should create a batch with a trailer when the job begins" do
      @batches.first.trailer.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "92",
        bankserv_user_code: "9534",
        first_sequence_number: "1",
        last_sequence_number: "4",
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        no_debit_records: "1",
        no_credit_records: "3",
        no_contra_records: "1",
        total_debit_value: "1000000",
        total_credit_value: "1000000",
        hash_total_of_homing_account_numbers: "138655402067"
      }

      @batches.second.trailer.data.should == {
        rec_id: "020",
        rec_status: "T",
        bankserv_record_identifier: "92",
        bankserv_user_code: "9534",
        first_sequence_number: "5",
        last_sequence_number: "8",
        first_action_date: Time.now.strftime("%y%m%d"),
        last_action_date: Time.now.strftime("%y%m%d"),
        no_debit_records: "1",
        no_credit_records: "3",
        no_contra_records: "1",
        total_debit_value: "1500000",
        total_credit_value: "1500000",
        hash_total_of_homing_account_numbers: "138655402058"
      }
    end
    
  end

  context "Building credit transmission with multiple sets" do
    
    before(:each) do
      tear_it_down
      
      @credit_service = Bankserv::CreditService.register(client_code: '10', client_name: "LDC USER 10 AFRICA (PTY)", client_abbreviated_name: 'ALIMITTST', user_code: "9534", generation_number: 37, transmission_status: "T", transmission_number: "1")
      debit_service = Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 37, transmission_status: "L", transmission_number: "1")
      
      @data = [{
         debit: {
           account_number: "907654321", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 500000, user_ref: 234, action_date: Date.today },
         credit:
           { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "235"}
      }]

      @data2 = [{
        debit: {
          account_number: "907654321", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Milnerton", amount: 500000, user_ref: 234, action_date: Date.today },
        credit:
          { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "235"}
      }]

      @hash = {
        type: 'credit',
        data: { type_of_service: "BATCH", batches: @data }
      }

      @hash2 = {
        type: 'credit',
        data: { type_of_service: "BATCH", batches: @data2 }
      }

      @credit_service.request(@hash)
      @credit_service.request(@hash2)
    end

    it "should build a transmission with 3 sets" do
      document = Bankserv::InputDocument.generate!(@credit_service)
      document.sets.size.should == 3
    end

  end
      
end
