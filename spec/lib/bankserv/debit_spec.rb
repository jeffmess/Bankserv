require 'spec_helper'

describe Bankserv::Debit do
  
  context "queuing a batch of debit orders" do
    
    before(:all) do
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
      
      @debit_service = Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
    end
    
    it "should be able to queue a request of debit orders" do
      @debit_service.request(@hash).should be_truthy
      Bankserv::Debit.all.each {|db| db.completed?.should be_falsey }
      Bankserv::Debit.all.each {|db| db.new?.should be_truthy }
    end
  
    it "should link all debit order to the credit record" do
      @debit_service.request(@hash)
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
      
      @debit_service = Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
    end
    
    it "should be able to queue a batched request of debit orders" do
      @debit_service.request(@hash).should be_truthy
      Bankserv::Debit.all.each {|db| db.completed?.should be_falsey }
      Bankserv::Credit.all.each {|db| db.new?.should be_truthy }
    end
  
    it "should link all debit order to their respective credit record" do
      @debit_service.request(@hash)
      Bankserv::Debit.all.map(&:batch_id).uniq.length.should == 2
    end
    
  end
  
  context "when processing an unpaid debit response" do
    
    before(:each) do
      @debit = create(:debit)
            
      @unpaid_response = {
        :rec_id=>"013", 
        :rec_status=>"T", 
        :transaction_type=>"50", 
        :transmission_date=>"20010111", 
        :original_sequence_number=>"3378", 
        :homing_branch_code=>"270124", 
        :homing_account_number=>"53090317766", 
        :amount=>"13755", 
        :user_ref=>"DEBIT5", 
        :rejection_reason=>"2", 
        :rejection_qualifier=>"0", 
        :distribution_sequence_number=>"0", 
        :homing_account_name=>"", 
        :response_status=>"unpaid"
      }
      
      @debit.process_response(@unpaid_response)
    end
    
    it "should be marked as unpaid if the response status is unpaid" do
      @debit.unpaid?.should be_truthy
    end
    
    it "should record the rejection reason code" do
      @debit.response[:rejection_reason].should == "2"
    end
    
    it "should record a rejection reason description" do
      @debit.response[:rejection_reason_description].should == "NOT PROVIDED FOR"
    end
    
    it "should record the rejection qualifier code" do
      @debit.response[:rejection_qualifier].should == "0"
    end
    
    it "should record the rejection qualifier description" do
      @debit.response[:rejection_qualifier_description].should be_nil
    end
    
  end
  
  context "when processing a redirect debit response" do
    
    before(:each) do
      @debit = create(:debit)
      
      @redirect_response = {
        :rec_id=>"017", 
        :rec_status=>"T", 
        :transaction_type=>"50", 
        :transmission_date=>"20010116", 
        :original_sequence_number=>"73", 
        :homing_branch=>"52749", 
        :homing_account=>"405662263", 
        :amount=>"9964", 
        :user_ref=>"DEBIT2", 
        :new_homing_branch=>"55", 
        :new_homing_account_number=>"405663293", 
        :new_homing_account_type=>"2", 
        :distribution_sequence_number=>"0", 
        :homing_account_name=>"", 
        :response_status=>"redirect"
      }
      
      @debit.process_response(@redirect_response)
    end
    
    it "should be marked as redirect if the response status is redirect" do
      @debit.redirect?.should be_truthy
    end
    
    it "should record the new homing branch" do
      @debit.response[:new_homing_branch].should == "55"
    end
    
    it "should record the new homing account number" do
      @debit.response[:new_homing_account_number].should == "405663293"
    end
    
    it "should record the new homing account type" do
      @debit.response[:new_homing_account_type].should == "2"
    end
    
  end
  
end
