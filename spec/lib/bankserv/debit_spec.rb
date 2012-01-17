require 'spec_helper'

describe Bankserv::Debit do
  
  context "queuing a batch of debit orders" do
    
    before(:all) do
      
      create(:configuration, client_code: "10", client_name: "LDC USER 10 AFRICA (PTY)", user_code: "9534", client_abbreviated_name: "ALIMITTST")
      @data = [{
        credit: {
          account_number: "907654321",
          branch_code: "632005",
          account_type: 'savings',
          id_number: '8207205263083',
          initials: "RC",
          account_name: "Rawson Milnerton",
          amount: 1000000,
          user_ref: 134,
          action_date: Date.today
        },
        debit: [
          { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "200"},
          { account_number: "45645645645", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "201"},
          { account_number: "78978978978", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 250000, action_date: Date.today, user_ref: "202"}
        ]
      }]
      
      @hash = {
        type: 'debit',
        data: { type_of_service: "SAMEDAY", batches: @data }
      }
    end
    
    it "should be able to queue a request of debit orders" do
      Bankserv::Debit.request(@hash).should be_true
      Bankserv::Debit.all.each {|db| db.processed?.should be_false }
    end
  
    it "should link all debit order to the credit record" do
      Bankserv::Debit.request(@hash)
      Bankserv::Debit.all.map(&:batch_id).uniq.length.should == 1
    end
    
  end
  
  context "queuing a batch of batched debit orders" do    
    before(:all) do
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
        data: {type_of_service: "ONE DAY", batches: @data}
      }
    end
    
    it "should be able to queue a batched request of debit orders" do
      Bankserv::Debit.request(@hash).should be_true
      Bankserv::Debit.all.each {|db| db.processed?.should be_false }
    end
  
    it "should link all debit order to their respective credit record" do
      Bankserv::Debit.request(@hash)
      Bankserv::Debit.all.map(&:batch_id).uniq.length.should == 2
    end
    
  end
end
