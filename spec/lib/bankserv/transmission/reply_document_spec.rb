require 'spec_helper'

describe Bankserv::ReplyDocument do
  include Helpers
  
  context "storing a reply transmission" do
    
    before(:all) do
      tear_it_down
      create(:configuration)
      
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
    
  end
  
  context "processing a reply transmission" do
    
    before(:each) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/reply_file.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::OutputDocument.store(@file_contents)
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
    
  end
  
  context "processing a reply file reporting that a transmission was rejected" do
    
    before(:all) do
      tear_it_down
      create(:configuration)
      
      @file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)
      
      @file_contents = File.open("./spec/examples/reply/rejected_transmission.txt", "rb").read
      @options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'output')

      @reply_document = Bankserv::ReplyDocument.store(@file_contents)
      
      @reply_document.process!
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