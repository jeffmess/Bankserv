require 'spec_helper'

describe Bankserv::OutputDocument do
  include Helpers

  context "processing an output document" do
    
    it "should raise an exception if the document has already been processed" do
      document = create(:output_document, :processed)
    
      lambda { document.process! }.should raise_error(Exception, "Document already processed")
    end
  end
  
  context "storing an output transmission containing an account holder verification set" do
    
    before(:all) do
      tear_it_down
      
      Bankserv::AHVService.register(client_code: '2236', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "1")
      
      @file_contents = File.open("./spec/examples/ahv_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @document = Bankserv::OutputDocument.store(@file_contents)
    end
    
    it "should mark the document as an output transmission" do
      @document.type.should == "output"
    end
    
    it "should record the client code on the document" do
      @document.client_code.should == "2236"
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
      
      Bankserv::AccountHolderVerification.for_reference("149505000000000223600000008000").first.completed?.should be_falsey
      Bankserv::AccountHolderVerification.for_reference("198841000000000223600000000000").first.completed?.should be_falsey
      Bankserv::AccountHolderVerification.for_reference("149205000000000223605000700000").first.completed?.should be_falsey
      
      @document.process!
      
      Bankserv::AccountHolderVerification.for_reference("149505000000000223600000008000").first.completed?.should be_truthy
      Bankserv::AccountHolderVerification.for_reference("198841000000000223600000000000").first.completed?.should be_truthy
      Bankserv::AccountHolderVerification.for_reference("149205000000000223605000700000").first.completed?.should be_truthy
    end
    
  end
  
  context "storing an output transmission containing an eft set of debit transactions" do

    before(:all) do
      tear_it_down
      Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

      @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
       
      @document = Bankserv::OutputDocument.store(@file_contents)
    end

    it "should mark the document as an output transmission" do
      @document.should be_output
    end
     
    it "should mark the document as requiring processing" do
      @document.should_not be_processed
    end
     
    it "should store a document, set and records that produce the same data as was provided" do
      @document.to_hash.should == @options
    end
     
  end
     
  context "processing an output document containing an eft set of debit transactions" do
    
    before(:each) do
      tear_it_down
      Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

      @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
      
      @document = Bankserv::OutputDocument.store(@file_contents)
    end
     
    it "should be able to process the document, updating any related debit or credit requests" do
      debits = []
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 7627, batch_id: 1, user_ref: "DEBIT1")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 9964, batch_id: 1, user_ref: "DEBIT2")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10851, batch_id: 2, user_ref: "DEBIT3")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 31700, batch_id: 3, user_ref: "DEBIT4")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 13755, batch_id: 3, user_ref: "DEBIT5")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 22935, batch_id: 4, user_ref: "DEBIT6")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15198, batch_id: 4, user_ref: "DEBIT7")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 12720, batch_id: 4, user_ref: "DEBIT8")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 9345, batch_id: 4, user_ref:  "DEBIT9")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 13420, batch_id: 4, user_ref: "DEBIT10")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15300, batch_id: 4, user_ref: "DEBIT11")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 7790, batch_id: 4, user_ref:  "DEBIT12")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 19698, batch_id: 4, user_ref: "DEBIT13")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 5000, batch_id: 4, user_ref:  "DEBIT14")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10420, batch_id: 4, user_ref: "DEBIT15")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10000, batch_id: 4, user_ref: "DEBIT16")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15000, batch_id: 4, user_ref: "DEBIT17")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10000, batch_id: 4, user_ref: "DEBIT18")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 16150, batch_id: 4, user_ref: "DEBIT19")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 12300, batch_id: 4, user_ref: "DEBIT20")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 20000, batch_id: 4, user_ref: "DEBIT21")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 6287, batch_id: 4, user_ref:  "DEBIT22")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 8954, batch_id: 4, user_ref:  "DEBIT23")
   
      counter = 1
   
      Bankserv::Debit.all.each{|debit| debit.completed?.should be_falsey}
      @document.process!
   
      Bankserv::Debit.all.each do |debit|
        (debit.completed? or debit.unpaid? or debit.redirect?).should be_truthy
     
        if debit.unpaid?
          debit.response.has_key?(:rejection_reason).should be_truthy
          debit.response.has_key?(:rejection_reason_description).should be_truthy
          debit.response.has_key?(:rejection_qualifier).should be_truthy
          debit.response.has_key?(:rejection_qualifier_description).should be_truthy
        elsif debit.redirect?
          debit.response.has_key?(:new_homing_branch).should be_truthy
          debit.response.has_key?(:new_homing_account_number).should be_truthy
          debit.response.has_key?(:new_homing_account_type).should be_truthy
        end
      end
    end

  end

  context "Processing an output file with errors" do
    before(:each) do
      tear_it_down

      @cs = Bankserv::CreditService.register(client_code: '04136', client_name: "RENTAL CONNECT PTY LTD", client_abbreviated_name: 'RAWSONPROP', user_code: "A855", generation_number: 6234, transmission_status: "L", transmission_number: "343")

      @request = Bankserv::Request.create!({
        type: "credit",
        data: {
          :type_of_service=>"BATCH", 
          :batches=>[{
            :debit=>{:account_number=>"4083387001", :id_number=>"", :initials=>"", :account_name=>"Blue Platinum Ventures (Busi. A/C)", :branch_code=>"632005", :account_type=>"current", 
              :amount=>705000, :user_ref=>6231, :action_date=>"2014-07-08".to_date}, 
            :credit=>{:account_number=>"62355554893", :id_number=>"5208105009082", :initials=>"", :account_name=>"Johannes Faasen", :branch_code=>"", :account_type=>"current", :amount=>705000, 
              :user_ref=>"REFUND D Order", :action_date=>"2014-07-08".to_date}}]}
      })

      @request.service_id = @cs.id
      @request.save!

      Bankserv::Credit.all.each {|x| x.status="pending";x.save!}

      @file_contents = File.open("./spec/examples/failed_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
      
      @document = Bankserv::OutputDocument.store(@file_contents)
      @document.process!
    end

    it "should mark the payment as failed" do
      Bankserv::Credit.all.each do |c|
        c.rejected?.should be_truthy
        c.response.first[:message].should == "TARGET ACCOUNT BRANCH INVALID"
      end
    end
  end
end
