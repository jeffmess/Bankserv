require 'spec_helper'

describe Bankserv::OutputDocument do
  include Helpers

  context "processing an output document" do
    
    it "should raise an exception if the document has already been processed" do
      document = create(:output_document, :processed)
    
      lambda { document.process! }.should raise_error(Exception, "Document already processed")
    end
    
    it "should mark the document as processed once the document's set has been processed" do
      document_set = mock(Bankserv::Set)
      document_set.should_receive(:process)
      
      document = create(:output_document)
      document.stub!(:set).and_return(document_set)

      document.process!
      Bankserv::Document.last.should be_processed
    end
  end
  
  context "storing an output transmission containing an account holder verification set" do
    
    before(:all) do
      tear_it_down
      
      Bankserv::Service.register(service_type: 'ahv', client_code: '12345', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "1")
      
      @file_contents = File.open("./spec/examples/ahv_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @document = Bankserv::OutputDocument.store(@file_contents)
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
      
      @document.process!
      
      Bankserv::AccountHolderVerification.for_reference("149505000000000223600000008000").first.completed?.should be_true
      Bankserv::AccountHolderVerification.for_reference("198841000000000223600000000000").first.completed?.should be_true
      Bankserv::AccountHolderVerification.for_reference("149205000000000223605000700000").first.completed?.should be_true
    end
    
  end
  
  context "storing an output transmission containing an eft set of debit transactions" do

    before(:all) do
      tear_it_down
      Bankserv::Service.register(service_type: 'debit', client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

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
      Bankserv::Service.register(service_type: 'debit', client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")

      @file_contents = File.open("./spec/examples/eft_output_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
      
      @document = Bankserv::OutputDocument.store(@file_contents)
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
      @document.process!
   
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
  
  
end