require 'spec_helper'

describe Bankserv::ReplyDocument do
  include Helpers
  
  context "storing a reply transmission" do
    
    before(:all) do
      tear_it_down
      Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      Bankserv::CreditService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      
      @file_contents = File.open("./spec/examples/reply/reply_file.txt", "rb").read
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

    it "should set the user ref to the headers user ref" do
      @document.user_ref.should == "123"
    end
    
  end
  
  context "processing a reply transmission" do
    
    before(:each) do
      tear_it_down
      Bankserv::DebitService.register(client_code: '10', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      Bankserv::CreditService.register(client_code: '10', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/reply_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::ReplyDocument.store(@file_contents)
    end
    
    it "should mark the original input document as ACCEPTED if the transmission was accepted" do
      @input_document.reply_status.should be_nil
      @reply_document.process!
      
      @input_document.reload
      @input_document.reply_status.should == "ACCEPTED"
    end
    
    it "should mark an EFT user set as ACCEPTED or REJECTED" do
      @reply_document.process!
      @input_document.reload
      
      @input_document.set.sets.each do |set|
        set.reply_status.should == "ACCEPTED"
      end
    end

    it "should update the tranmission number of the service" do
      @reply_document.process!
      Bankserv::DebitService.last.config[:transmission_number].should == "2"
    end
    
  end

  context "processing an accepted ahv reply file" do
    before(:all) do
      tear_it_down
      Bankserv::AHVService.register(client_code: '10', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      @file_contents = File.open("./spec/examples/ahv_input_file.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)

      @file_contents = File.open("./spec/examples/reply/reply2.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::ReplyDocument.store(@file_contents)
      
      @reply_document.process!
      @input_document.reload
    end

    it "should mark the reply documents reply status as accepted" do
      @input_document.reply_status.should == "ACCEPTED"
    end
  end

  context "processing a reply file with 1 accepted transaction" do
    before(:each) do
      tear_it_down

      @cs = Bankserv::CreditService.register(client_code: '04136', client_name: "RENTAL CONNECT PTY LTD", client_abbreviated_name: 'RAWSONPROP', user_code: "A855", generation_number: 6234, transmission_status: "L", transmission_number: "343")

      @file_contents = File.open("./spec/examples/simple_input_file.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)

      @request = Bankserv::Request.create!({
        type: "credit",
        data: {
          :type_of_service=>"BATCH", 
          :batches=>[{
            :debit=>{:account_number=>"4083414606", :id_number=>"", :initials=>"", :account_name=>"Blue Platinum Ventures (Busi. A/C)", :branch_code=>"632005", :account_type=>"current", :amount=>1725000, :user_ref=>6378, :action_date=>"2014-07-12".to_date}, 
            :credit=>{:account_number=>"070285179", :id_number=>"", :initials=>"", :account_name=>"The Sunset Beach Trust", :branch_code=>"004255", :account_type=>"cheque", :amount=>1725000, :user_ref=>"Deposit to LL Algoa", :action_date=>"2014-07-12".to_date}
          }]
        }
      })

      @request.service_id = @cs.id
      @request.save!

      Bankserv::Credit.all.each {|x| x.status="pending";x.save!}

      @file_contents = File.open("./spec/examples/reply/accepted_reply.txt", "rb").read
      #@options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')
      
      @document = Bankserv::ReplyDocument.store(@file_contents)
      @document.process!
    end

    it "should mark the credit entries as accepted" do
      Bankserv::Credit.all.each do |c|
        c.accepted?.should be_true
      end
    end
  end
  
  context "processing a reply file reporting that a transmission was rejected" do
    
    before(:all) do
      tear_it_down
      Bankserv::DebitService.register(client_code: '10', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      Bankserv::CreditService.register(client_code: '10', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1")
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/rejected_transmission.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::ReplyDocument.store(@file_contents)
      
      @reply_document.process!
      @input_document.reload
    end

    it "should not update the tranmission number of the services" do
      Bankserv::DebitService.last.config[:transmission_number].should == "1"
      Bankserv::CreditService.last.config[:transmission_number].should == "1"
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
        record.error.should == [{:code=>"12345", :message=>"HI THIS IS REJECTED MESSAGE"}]
      end
    end
    
    context "processing an accepted report reply record" do
      pending
    end
    
  end

  context "Process a reply file with accepted and rejected records" do

    before(:each) do
      tear_it_down
      @cs = Bankserv::CreditService.register(client_code: '04136', client_name: "RENTAL CONNECT PTY LTD", client_abbreviated_name: 'RAWSONPROP', user_code: "A855", generation_number: 6365, transmission_status: "L", transmission_number: "350", sequence_number: 57)

      @file_contents = File.open("./spec/examples/accepted_and_rejected_input_file.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)

      options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'input')
      options[:data].each do |entry|
        if entry[:data].count == 4
          c = entry[:data].map {|x| x[:data]}
          request = Bankserv::Request.create!({
            type: "credit",
            data: {
              :type_of_service=>"BATCH", 
              :batches=>[{
                :debit=>{:account_number=>c[2][:homing_account_number], :id_number=>"", :initials=>"", :account_name=>c[2][:homing_account_name], :branch_code=>c[2][:homing_branch], :account_type=>"cheque", :amount=>c[2][:amount], :user_ref=>c[2][:user_ref].gsub("RAWSONPROPCONTRA", ""), :action_date=>"2014-07-15".to_date}, 
                :credit=>{:account_number=>c[1][:homing_account_number], :id_number=>"", :initials=>"", :account_name=>c[1][:homing_account_name], :branch_code=>c[1][:homing_branch], :account_type=>"cheque", :amount=>c[1][:amount], :user_ref=>c[1][:user_ref].gsub("RAWSONPROP", ""), :action_date=>"2014-07-15".to_date}
              }]
            }
          })

          request.service_id = @cs.id
          request.save!
        end
      end

      Bankserv::Credit.all.each {|x| x.status="pending";x.save!}

      @file_contents = File.open("./spec/examples/reply/accepted_and_rejected_transactions.txt", "rb").read
      
      @document = Bankserv::ReplyDocument.store(@file_contents)
      @document.process!
      @cs.reload
    end

    it "should reset the credit service generation number to 6355" do
      @cs.config[:generation_number].should == 6355
    end

    it "should set the credit service sequence number to 35" do
      @cs.config[:sequence_number].should == 35
    end

    it "should have rejected transactions" do
      Bankserv::Credit.all.each do |c|

      end
    end

    it "should reset some of the credits to new" do

    end

  end
  
  
end