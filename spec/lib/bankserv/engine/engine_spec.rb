require 'spec_helper'

describe Bankserv::Engine do
  
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
  
  context "Lifecycle of processing work" do
    
    before(:all) do
      t = Time.local(2012, 1, 23, 10, 5, 0)
      Timecop.travel(t)
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      @queue = Bankserv::Engine.new
    end
    
    it "should be able to start processing work" do
      @queue.start!.should be_true
    end
    
    it "should be set to running" do
      @queue.running?.should be_true
    end
    
    it "should be able to return a list of reply files" do
      Bankserv::Engine.reply_files.should == ["REPLY0412153000.txt"]
    end
    
    it "should be able to return a list of output files" do
      Bankserv::Engine.output_files.should == ["OUTPUT0412153500.txt"]
    end
    
    it "should be able to process reply files" do
      pending
      @queue.process_reply_files
    end
    
    it "should be able to process output files" do
      pending
    end
    
    it "should process any documents that have work" do
      pending
    end
    
    it "should be able to set the process to finished" do
      @queue.finish!.should be_true
      @queue.running?.should be_false
      @queue.process.response.should == "Success"
      @queue.process.success.should be_true
    end
    
  end
  
end