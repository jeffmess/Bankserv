require 'spec_helper'

describe Bankserv::Engine do
  include Helpers
  
  context "Prepare engine" do
    
    it "should contain default values from the migration" do
      Bankserv::Engine.config.should == { interval_in_minutes: 15, input_directory: "/tmp", output_directory: "/tmp" }
    end
    
    it "should be able to update engines config" do
      Bankserv::Engine.interval = 15
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.config[:interval_in_minutes].should == 15
      Bankserv::Engine.config[:output_directory].should == Dir.pwd + "/spec/examples/host2host"
    end
    
    it "should not have any running processes" do
      Bankserv::Engine.running?.should be_false
    end
    
  end
  
  context "Testing individual methods of engine" do
    
    before(:all) do
      t = Time.local(2012, 1, 23, 10, 5, 0)
      Timecop.travel(t)
      file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      Bankserv::Document.store_input_document(file_contents)
      
      Bankserv::Document.last.mark_processed!
      
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.input_directory = Dir.pwd + "/spec/examples/host2host"
      
      @queue = Bankserv::Engine.new
    end
    
    it "should be able to start processing work" do
      @queue.start!.should be_true
    end
    
    it "should be set to running" do
      @queue.running?.should be_true
    end
    
    it "should be expecting a reply file" do
      @queue.expecting_reply_file?.should be_true
    end
    
    it "should be able to return a list of reply files" do
      Bankserv::Engine.reply_files.should == ["REPLY0412153000.txt"]
    end
    
    it "should be able to return a list of output files" do
      Bankserv::Engine.output_files.should == ["OUTPUT0412153500.txt"]
    end
    
    it "should be able to process reply files" do
      @queue.process_reply_files
      Bankserv::Document.first.reply_status.should == "ACCEPTED"
      @queue.expecting_reply_file?.should be_false
    end
    
    it "should be able to process output files" do
      pending
    end
    
    it "should be able to process any documents that have work" do
      
    end
    
    it "should be able to set the process to finished" do
      @queue.finish!.should be_true
      @queue.running?.should be_false
      @queue.process.response.should == "Success"
      @queue.process.success.should be_true
    end
    
  end
  
  context "Processing work. Start to Finish." do
    
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
      
      Bankserv::Configuration.stub!(:live_env?).and_return(true)
      Bankserv::Document.stub!(:fetch_next_transmission_number).and_return("846")
      Bankserv::Record.create! record_type:"standard_record", data: {user_sequence_number: 77}, set_id: 76876
      
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.input_directory = Dir.pwd + "/spec/examples/host2host"
      
      @queue = Bankserv::Engine.new
    end
    
    after(:all) do
      Dir.glob(Dir.pwd + "/spec/examples/host2host/INPUT*.txt").each do |input_file|
        File.delete(input_file)
      end
    end
    
    it "should process the document" do
      @queue.process_input_files
      @document = Bankserv::Document.last
      @document.processed.should be_true
      @queue.expecting_reply_file?.should be_true
    end
    
    it "should write a file to the input directory" do
      (Dir.glob(Dir.pwd + "/spec/examples/host2host/INPUT*.txt").size == 1).should be_true
    end
    
  end
  
end