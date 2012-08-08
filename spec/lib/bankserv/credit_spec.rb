require 'spec_helper'

describe Bankserv::Credit do
  
  context "queuing a batch of credit orders" do
    
    before(:all) do
      @data = [{
        debit: {
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
        credit: [
          { account_number: "13123123123", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "200"},
          { account_number: "45645645645", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "201"},
          { account_number: "78978978978", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 250000, action_date: Date.today, user_ref: "202"}
        ]
      }]
      
      @hash = {
        type: 'credit',
        data: { batches: @data, type_of_service: "SAMEDAY"}
      }
      
      @credit_service = Bankserv::CreditService.register(client_code: '12345', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "9534", transmission_status: "L", transmission_number: "1")
    end
    
    it "should be able to queue a request of credit orders" do
      @credit_service.request(@hash).should be_true
      Bankserv::Credit.all.each {|db| db.completed?.should be_false }
      Bankserv::Credit.all.each {|db| db.new?.should be_true }
    end
  
    it "should link all debit order to the credit record" do
      @credit_service.request(@hash)
      Bankserv::Credit.all.map(&:batch_id).uniq.length.should == 1
    end
    
  end
  
  context "queuing a batch of batched credit orders" do    
    before(:each) do
      @credit_service = Bankserv::CreditService.register(client_code: '12345', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "9534", transmission_status: "L", transmission_number: "1")
      
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
          account_number: "907654522", branch_code: "632005", account_type: 'savings', id_number: '8207205263083', initials: "RC", account_name: "Rawson Claremont", amount: 1500000, user_ref: 300, action_date: Date.today },
        credit: [
          { account_number: "13123123122", branch_code: "123123", account_type: "savings", id_number: "198273981723", initials: "WC", account_name: "Tenant", amount: 500000, action_date: Date.today, user_ref: "301"},
          { account_number: "45645645642", branch_code: "123123", account_type: "savings", id_number: "198273922723", initials: "WX", account_name: "Tefant", amount: 250000, action_date: Date.today, user_ref: "302"},
          { account_number: "78978978972", branch_code: "789789", account_type: "savings", id_number: "197873933723", initials: "WB", account_name: "Tebant", amount: 750000, action_date: Date.today, user_ref: "303"}
        ]
      }]
      
      @hash = {
        type: 'credit',
        data: {batches: @data, type_of_service: "SAMEDAY"}
      }
    end
    
    it "should be able to queue a batched request of credit orders" do
      @credit_service.request(@hash).should be_true
      Bankserv::Credit.all.each {|db| db.completed?.should be_false }
      Bankserv::Credit.all.each {|db| db.new?.should be_true }
    end
  
    it "should link all debit order to their respective credit record" do
      @credit_service.request(@hash)
      Bankserv::Credit.all.map(&:batch_id).uniq.length.should == 2
    end
  end
end
