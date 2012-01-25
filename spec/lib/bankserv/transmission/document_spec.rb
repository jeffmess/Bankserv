require 'spec_helper'

describe Bankserv::Document do
  include Helpers

  context "processing an output document" do
    it "should raise an exception if the document is not an output document" do
      document = create(:document, :input)
    
      lambda { Bankserv::Document.process_output_document(document) }.should raise_error(Exception, "Expected output document")
    end
    
    it "should raise an exception if the document has already been processed" do
      document = create(:document, :output, :processed)
    
      lambda { Bankserv::Document.process_output_document(document) }.should raise_error(Exception, "Document already processed")
    end
    
    it "should mark the document as processed once the document's set has been processed" do
      document_set = mock(Bankserv::Set)
      document_set.should_receive(:process)
      
      document = create(:document, :output)
      document.stub!(:set).and_return(document_set)

      Bankserv::Document.process_output_document(document)
      Bankserv::Document.last.should be_processed
    end
  end
  
  context "building a transmission document containing two account holder verification requests" do
  
    before(:each) do
      tear_it_down
      create(:configuration)
    
      ahv_attributes = {
        bank_account: {
          account_number: "1094402524",
          branch_code: "250255",
          account_type: 'savings',
          id_number: '6703085829086',
          initials: "M",
          account_name: "CHAUKE"
        },
        user_ref: "149505000060000223600000000000"
      }
      
      Bankserv::AccountHolderVerification.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
      ahv.internal_user_ref = "AHV1"
      ahv.save!
    
      ahv_attributes = {
        bank_account: {
          account_number: "2968474669",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '6103120039082',
          initials: "A",
          account_name: "VAN MOLENDORF"
        },
        user_ref: "198841000060000223600000000000"
      }
      
      Bankserv::AccountHolderVerification.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
      ahv.internal_user_ref = "AHV2"
      ahv.save!
      
      ahv_attributes = {
        bank_account: {
          account_number: "2492008177",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '8801261110087',
          initials: "U",
          account_name: "NKWEBA"
        },
        user_ref: "149205000060000223600000000000"
      }
      
      Bankserv::AccountHolderVerification.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
      ahv.internal_user_ref = "AHV3"
      ahv.save!
      
      Bankserv::Configuration.should_receive(:department_code).and_return("000001")
      t = Time.local(2009, 7, 3, 10, 5, 0)
      Timecop.travel(t)
      
      Bankserv::Configuration.stub!(:reserve_user_generation_number!).and_return("1")
      Bankserv::Document.stub!(:fetch_next_transmission_number).and_return("0")
      Bankserv::Configuration.stub!(:live_env?).and_return(true)
    
      Bankserv::Document.generate!(
        client_code: "2236", 
        client_name: "TEST", 
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
    
    it "should be able to mark a document as processed" do
      @document.mark_processed!
      @document.processed.should be_true
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
      
      debit = Bankserv::Debit.test_request({
        type: 'debit',
        data: {
          type_of_service: "CORPSSV",
          batches: [{
            credit: {
              account_number: "4053538939", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 16028000, user_ref: "CONTRA1040524 08", action_date: Date.today
            },
            debit: [
              { account_number: '1019611899', branch_code: "632005", account_type: "1", id_number: '', amount: 1000,    action_date: Date.today, account_name: "HENNIE DU TOIT",  user_ref: 'SPP   1040524 01'},
              { account_number: '1019801892', branch_code: "632005", account_type: "1", id_number: '', amount: 2000,    action_date: Date.today, account_name: "TYRONE DREYDEN",  user_ref: "SPP   1040524 02"},
              { account_number: '1021131896', branch_code: "632005", account_type: "1", id_number: '', amount: 3000,    action_date: Date.today, account_name: "KEITH MEIKLEJOHN",user_ref: "SPP   1040524 03"},
              { account_number: '1022131890', branch_code: "632005", account_type: "1", id_number: '', amount: 4000,    action_date: Date.today, account_name: "CHRISTO SPIES",   user_ref: "SPP   1040524 04"},
              { account_number: '1057401890', branch_code: "632005", account_type: "1", id_number: '', amount: 6005000, action_date: Date.today, account_name: "DENISE RETIEF",   user_ref: "SPP   1040524 05"}, 
              { account_number: '18000010304',branch_code: "632005", account_type: "1", id_number: '', amount: 3006000, action_date: Date.today, account_name: "PETER HAUPT",     user_ref: "SPP   1040524 06"},  
              { account_number: '1020861726', branch_code: "632005", account_type: "1", id_number: '', amount: 7007000, action_date: Date.today, account_name: "HADLEY RAW",      user_ref: "SPP   1040524 07"}    
            ]
          }, {
            credit: {
              account_number: "1004651894", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 4280000, user_ref: "CONTRA2040525 08", action_date: Date.tomorrow
            },
            debit: [
              { account_number: '1006221897', branch_code: "632005", account_type: "1", id_number: '', amount: 10000,  action_date: Date.tomorrow, account_name: "HENNIE DU TOIT",  user_ref: 'SPP   2040525 01'},
              { account_number: '1006241898', branch_code: "632005", account_type: "1", id_number: '', amount: 20000,  action_date: Date.tomorrow, account_name: "TYRONE DREYDEN",  user_ref: "SPP   2040525 02"},
              { account_number: '1009831891', branch_code: "632005", account_type: "1", id_number: '', amount: 4030000,action_date: Date.tomorrow, account_name: "KEITH MEIKLEJOHN",user_ref: "SPP   2040525 03"},
              { account_number: '1010000609', branch_code: "632005", account_type: "1", id_number: '', amount: 40000,  action_date: Date.tomorrow, account_name: "CHRISTO SPIES",   user_ref: "SPP   2040525 04"},
              { account_number: '1019141892', branch_code: "632005", account_type: "1", id_number: '', amount: 50000,  action_date: Date.tomorrow, account_name: "DENISE RETIEF",   user_ref: "SPP   2040525 05"}, 
              { account_number: '1019591898', branch_code: "632005", account_type: "1", id_number: '', amount: 60000,  action_date: Date.tomorrow, account_name: "PETER HAUPT",     user_ref: "SPP   2040525 06"},  
              { account_number: '1020861726', branch_code: "632005", account_type: "1", id_number: '', amount: 70000,  action_date: Date.tomorrow, account_name: "HADLEY RAW",      user_ref: "SPP   2040525 07"}
            ]
          }]
        }
      })
    end
    
    it "should build a new document with debit sets and a header" do
      Bankserv::Document.stub!(:fetch_next_transmission_number).and_return("621")
      
      Bankserv::Document.generate_test!(
        th_for_use_of_ld_user: ""
      )
      
      document = Bankserv::Document.last
      hash = document.to_hash
      
      string = File.open("./spec/examples/debit_eft_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options
    end
  
  end
  
  context "building a transmission document credit order requests" do
    before(:all) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::AccountHolderVerification.delete_all
      Bankserv::Debit.delete_all
      Bankserv::Credit.delete_all
      
      tear_it_down      
      create(:configuration, client_code: "986", client_name: "TESTTEST", user_code: "9999", user_generation_number: 846, client_abbreviated_name: "TESTTEST")
      
      t = Time.local(2008, 8, 8, 10, 5, 0)
      Timecop.travel(t)
      
      create_credit_request
    end
    
    it "should build a new document with a credit set" do
      #Bankserv::Configuration.stub!(:reserve_transmission_number!).and_return("846")
      Bankserv::Configuration.stub!(:live_env?).and_return(true)
      Bankserv::Document.stub!(:fetch_next_transmission_number).and_return("846")
      
      Bankserv::Record.create! record_type:"standard_record", data: {user_sequence_number: 77}, set_id: 76876
        
      Bankserv::Document.generate!(
        th_for_use_of_ld_user: ""
      )
      
      document = Bankserv::Document.last
      hash = document.to_hash
      
      string = File.open("./spec/examples/credit_eft_input.txt", "rb").read
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
      ahv1.internal_user_ref = "AHV1"
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
      ahv2.internal_user_ref = "AHV2"
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
      ahv3.internal_user_ref = "AHV3"
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
  
  context "storing an output transmission containing an eft set of debit transactions" do

    before(:all) do
      tear_it_down
      create(:configuration)

      @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
       
      @document = Bankserv::Document.store_output_document(@file_contents)
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
      create(:configuration)

      @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
      
      @document = Bankserv::Document.store_output_document(@file_contents)
    end
     
    it "should be able to process the document, updating any related debit or credit requests" do
      debits = []
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 7627, batch_id: 1, user_ref: "A LDC TESTY PREMIE AL0597626X5")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 9964, batch_id: 1, user_ref: "A LDC TESTY PREMIE AL0394056X3")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10851, batch_id: 2, user_ref: "A LDC TESTY PREMIE AL0620127X9")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 31700, batch_id: 3, user_ref: "A LDC TESTM PREMIE AL0876267X2")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 13755, batch_id: 3, user_ref: "A LDC TESTY PREMIE AL0699555X1")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 22935, batch_id: 4, user_ref: "A LDC TESTSALARIS  BL ROODT")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15198, batch_id: 4, user_ref: "A LDC TESTKREDITEUR L0844622KL")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 12720, batch_id: 4, user_ref: "A LDC TESTVERSEKERING  01BLOR3")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 9345, batch_id: 4, user_ref:  "A LDC TESTSALARIS SOEKIE 12345")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 13420, batch_id: 4, user_ref: "A LDC TESTSALARIS  BL ROODT")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15300, batch_id: 4, user_ref: "A LDC TESTSALARIS  BL ROODT")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 7790, batch_id: 4, user_ref:  "A LDC TESTSANLAM   AL0849 61X3")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 19698, batch_id: 4, user_ref: "A LDC TESTSOUTHERN LIFE 4627K5")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 5000, batch_id: 4, user_ref:  "A LDC TESTHUISVERBAND 98173587")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10420, batch_id: 4, user_ref: "A LDC TESTPERSOONLIKE LENING")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10000, batch_id: 4, user_ref: "A LDC TESTSPAARKLUB OKT 2001")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 15000, batch_id: 4, user_ref: "A LDC TESTY PREMIE XAZAP1163V5")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 10000, batch_id: 4, user_ref: "A LDC TESTQ PREMIE BLASNK158X4")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 16150, batch_id: 4, user_ref: "A LDC TESTY PREMIE ALONE6728X1")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 12300, batch_id: 4, user_ref: "A LDC TESTM PREMIUM LZANA602F3")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 20000, batch_id: 4, user_ref: "A LDC TESTY PREMIE SP0001453X0")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 6287, batch_id: 4, user_ref:  "A LDC TESTW INSTALMENT ND263XZ")
      debits << Bankserv::Debit.create!(record_type: "standard", amount: 8954, batch_id: 4, user_ref:  "A LDC TESTY PROTECTION 9697523")
   
      counter = 1
   
      debits.each do |debit|
        debit.internal_user_ref = "DEBIT#{counter}"
        debit.save!
        counter += 1
      end

      Bankserv::Debit.all.each{|debit| debit.completed?.should be_false}
      Bankserv::Document.process_output_document(@document)
   
      Bankserv::Debit.all.each do |debit|
        (debit.completed? or debit.unpaid? or debit.redirect?).should be_true
     
        if debit.unpaid?
          debit.response.has_key?(:rejection_reason).should be_true
          debit.response.has_key?(:rejection_reason_description).should be_true
          debit.response.has_key?(:rejection_qualifier).should be_true
          debit.response.has_key?(:rejection_qualifier_description).should be_true
        elsif debit.redirect?
          debit.response.has_key?(:new_homing_branch).should be_true
          debit.response.has_key?(:new_homing_account_number).should be_true
          debit.response.has_key?(:new_homing_account_type).should be_true
        end
      end
    end

  end
  
  context "storing a reply transmission" do
    
    before(:all) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/reply/reply_file.txt", "rb").read
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
    
  end
  
  context "processing a reply transmission" do
    
    before(:each) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::Document.store_input_document(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/reply_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::Document.store_output_document(@file_contents)
    end
    
    it "should mark the original input document as ACCEPTED if the transmission was accepted" do
      @input_document.reply_status.should be_nil
      
      Bankserv::Document.process_output_document(@reply_document)
      
      @input_document.reload
      @input_document.reply_status.should == "ACCEPTED"
    end
    
    it "should mark an EFT user set as ACCEPTED or REJECTED" do
      Bankserv::Document.process_output_document(@reply_document)
      @input_document.reload
      
      @input_document.set.sets.each do |set|
        set.reply_status.should == "ACCEPTED"
      end
    end
    
  end
  
  context "processing a reply file reporting that a transmission was rejected" do
    
    before(:all) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::Document.store_input_document(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/rejected_transmission.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::Document.store_output_document(@file_contents)
      
      Bankserv::Document.process_output_document(@reply_document)
      @input_document.reload
    end
    
    context "processing a transmission status record" do
      it "should mark the document's reply status as REJECTED" do
        @input_document.reply_status.should == "REJECTED"
      end
    end
    
    context "processing a transmission rejected reason record" do
      it "should record the transmission rejection error code" do
        @input_document.error[:code].should == "12345"
      end

      it "should record the transmission rejection error message" do
        @input_document.error[:message].should == "HI THIS IS ERROR"
      end
    end
    
    context "processing a rejected message record" do
      it "should update the related record with error information" do
        record = @input_document.set.sets.last.transactions.first
        record.error[:code].should == "12345"
        record.error[:message].should == "HI THIS IS REJECTED MESSAGE"
      end
    end
    
    context "processing an accepted report reply record" do
      pending
    end
    
  end
   
end
