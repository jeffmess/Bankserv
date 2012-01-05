require 'spec_helper'

describe Bankserv::Debit do
  
  context "queuing a batch of debit orders" do
    
    before(:all) do
      @data = {
        credit: {
          account_number: "907654321",
          branch_code: "632005",
          account_type: 'savings',
          id_number: '8207205263083',
          initials: "RC",
          account_name: "Rawson Milnerton",
          amount: 1000000,
          user_ref: 134
        },
        debit: [
          { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "200"},
          { account_number: "45645645645", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "201"},
          { account_number: "78978978978", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 250000, action_date: Date.today, user_ref: "202"}
        ]
      }
      
      @hash = {
        type: 'debit',
        data: @data
      }
    end
    
    it "should be able to queue a request of debit orders" do
      Bankserv::Debit.request(@hash).should be_true
    end
  
    it "should link all debit order to the credit record" do
      
    end
    
    it "should" do
      
    end
  end
      
end