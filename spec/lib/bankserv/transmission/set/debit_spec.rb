require 'spec_helper'

describe Bankserv::Transmission::UserSet::Debit do
  
  context "Building a debit batch" do
    
    before(:all) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::Debit.delete_all
      
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
      batch = Bankserv::Transmission::UserSet::Debit.create_sets
      batch.save
      
      
      
      batch.records.each do |r|
        # puts r.inspect
        # puts r.data.inspect
      end
      
      # puts batch.records.map(&:data).inspect
      # batch.save
      # batch.header.data.should == {
      #   rec_id: "030", 
      #   rec_status: "T", 
      #   gen_no: batch.id.to_s,
      #   dept_code: nil
      # }
    end
    
    it "should create a batch of transactions when the job begins" do
      pending
      # batch = Bankserv::Transmission::UserSet::AccountHolderVerification.create_sets.first
      # batch.save
      # batch.transactions.first.type.should == "external_account_detail"
    end
    
    it "should create a batch with a trailer when the job begins" do
      pending
      # Bankserv::AccountHolderVerification.unprocessed.send(:internal).inspect
      # 
      # batch = Bankserv::Transmission::UserSet::AccountHolderVerification.create_sets.first
      # batch.save
      # 
      # batch.trailer.data.should == {
      #   rec_id: "039", 
      #   rec_status: "T", 
      #   no_det_recs: 1.to_s, 
      #   acc_total: @bank_hash[:account_number]
      # }
      
    end
  end
      
end
