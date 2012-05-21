require 'spec_helper'

describe Bankserv::Engine do
  include Helpers
  
  before(:all) do
    FileUtils.mkdir(Dir.pwd + "/spec/examples/host2host/archives") unless File.directory?(Dir.pwd + "/spec/examples/host2host/archives")
    FileUtils.copy(Dir.pwd + "/spec/examples/tmp/OUTPUT0412153500.txt", Dir.pwd + "/spec/examples/9534/incoming/")
    FileUtils.copy(Dir.pwd + "/spec/examples/tmp/REPLY0412153000.txt", Dir.pwd + "/spec/examples/9534/incoming/")
    Bankserv::EngineConfiguration.create!(interval_in_minutes: 15, input_directory: "/tmp", output_directory: "/tmp", archive_directory: "/tmp")
  end
  
  after(:all) do
    Dir.glob(Dir.pwd + "/spec/examples/host2host/*.txt").each do |input_file|
      File.delete(input_file)
    end
    
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/host2host/archives", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/9534/incoming/*", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/9534/outgoing/*", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/9534/archive/*", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/9999/outgoing/*", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/99999/outgoing/*", secure: true)
    FileUtils.rm_rf(Dir.pwd + "/spec/examples/95345/outgoing/*", secure: true)
    File.delete(Dir.pwd + "/spec/tmp/harry.txt")
    File.delete(Dir.pwd + "/spec/tmp/sally.txt")
    File.delete(Dir.pwd + "/spec/tmp/molly.txt")
  end
  
  context "Prepare engine" do
    
    it "should contain default values from the migration" do
      Bankserv::Engine.config.should == { interval_in_minutes: 15, input_directory: "/tmp", output_directory: "/tmp", archive_directory: "/tmp" }
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
  
  # it "should retrieve services which can transmit input documents" do
  #   debit_service = Bankserv::DebitService.register(client_code: '10', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "9534", transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/9534/outgoing", incoming_directory: Dir.pwd + "/spec/examples/9534/incoming", reply_directory: Dir.pwd + "/spec/examples/9534/incoming", archive_directory: Dir.pwd + "/spec/examples/9534/archive")
  #   credit_service = Bankserv::CreditService.register(client_code: '12345', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "95345", transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/95345/outgoing", incoming_directory: Dir.pwd + "/spec/examples/95345/incoming", reply_directory: Dir.pwd + "/spec/examples/95345/incoming", archive_directory: Dir.pwd + "/spec/examples/95345/archive")    
  #   ahv_service = Bankserv::AHVService.register(client_code: '12345', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "1", user_code: "999", outgoing_directory: Dir.pwd + "/spec/examples/9999/outgoing", incoming_directory: Dir.pwd + "/spec/examples/9999/incoming", reply_directory: Dir.pwd + "/spec/examples/9999/incoming", archive_directory: Dir.pwd + "/spec/examples/9999/archive")
  #   statement_service = Bankserv::StatementService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "99999", generation_number: 1, transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/99999/outgoing", incoming_directory: Dir.pwd + "/spec/examples/99999/incoming", reply_directory: Dir.pwd + "/spec/examples/99999/incoming", archive_directory: Dir.pwd + "/spec/examples/99999/archive")
  #   
  #   input_services = Bankserv::Engine.new.input_services
  #   input_services.include?(debit_service).should be_true
  #   input_services.include?(credit_service).should be_true
  #   input_services.include?(ahv_service).should be_true
  #   input_services.include?(statement_service).should be_false
  # end
  
  context "Testing individual methods of engine" do
    
    before(:all) do
      @debit_service = Bankserv::DebitService.register(client_code: '10', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "9534", transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/9534/outgoing", incoming_directory: Dir.pwd + "/spec/examples/9534/incoming", reply_directory: Dir.pwd + "/spec/examples/9534/incoming", archive_directory: Dir.pwd + "/spec/examples/9534/archive")
      t = Time.local(2012, 1, 23, 10, 5, 0)
      Timecop.travel(t)
      file_contents = File.open("./spec/examples/eft_input_with_2_sets.txt", "rb").read
      Bankserv::InputDocument.store(file_contents)
      
      Bankserv::Document.last.mark_processed!
      
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.input_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.archive_directory = Dir.pwd + "/spec/examples/host2host/archives"
      
      @engine = Bankserv::Engine.new(@debit_service)
    end
    
    it "should be able to start processing work" do
      @engine.start!.should be_true
    end
    
    it "should be set to running" do
      @engine.running?.should be_true
    end
    
    it "should be expecting a reply file" do
      @engine.expecting_reply_file?(@debit_service).should be_true
    end
    
    it "should be able to return a list of reply files" do
      Bankserv::Engine.reply_files(@debit_service).should == ["REPLY0412153000.txt"]
    end
    
    it "should be able to return a list of output files" do
      Bankserv::Engine.output_files(@debit_service).should == ["OUTPUT0412153500.txt"]
    end
    
    it "should be able to process reply files" do
      @engine.process_reply_files
      Bankserv::Document.first.reply_status.should == "ACCEPTED"
      @engine.expecting_reply_file?(@debit_service).should be_false
    end
    
    it "should be able to process output files" do
      @engine.process_output_files
    end
    
    it "should be able to set the process to finished" do
      @engine.finish!.should be_true
      @engine.running?.should be_false
      @engine.process.success.should be_true
    end
    
    it "should not have any processes running" do
      Bankserv::Engine.running?.should be_false
    end
    
  end
  
  context "Processing an input document." do
    
    before(:all) do
      tear_it_down      
      
      Timecop.travel(Time.local(2008, 8, 8, 10, 5, 0))
      Bankserv::EngineConfiguration.create!(interval_in_minutes: 15, input_directory: "/tmp", output_directory: "/tmp", archive_directory: "/tmp")
      @service = Bankserv::CreditService.register(client_code: '12345', client_name: "RCTEST", client_abbreviated_name: 'RCTEST', user_code: "9534", transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/9534/outgoing", incoming_directory: Dir.pwd + "/spec/examples/9534/incoming", reply_directory: Dir.pwd + "/spec/examples/9534/incoming", archive_directory: Dir.pwd + "/spec/examples/9534/archive")
      
      create_credit_request(@service)
      
      Bankserv::Engine.output_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.input_directory = Dir.pwd + "/spec/examples/host2host"
      Bankserv::Engine.archive_directory = Dir.pwd + "/spec/examples/host2host/archives"
      
      @engine = Bankserv::Engine.new(@service)
      @engine.start! # create a process
    end
     
    it "should process the document" do
      @engine.process_input_files
      @document = Bankserv::Document.last
      @document.processed.should be_true
      @engine.expecting_reply_file?(@service).should be_true
    end
    
    it "should write a file to the input directory" do
      (Dir.glob("#{@service.config[:outgoing_directory]}/INPUT*.txt").size == 1).should be_true
    end
    
  end
  
  context "integration testing" do
    pending
    
    # before(:all) do
    #   tear_it_down
    #   Timecop.travel(Time.local(2012, 4, 10, 10, 5, 0))
    #   @tmpdir = Dir.pwd + "/spec/tmp"
    #   @ahv_service = Bankserv::AHVService.register(client_code: '12345', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "1", user_code: '95345', outgoing_directory: Dir.pwd + "/spec/examples/95345/outgoing", incoming_directory: Dir.pwd + "/spec/examples/95345/incoming", reply_directory: Dir.pwd + "/spec/examples/95345/incoming", archive_directory: Dir.pwd + "/spec/examples/95345/archive")
    #   @debit_service = Bankserv::DebitService.register(client_code: '12346', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "1", user_code: '99999',outgoing_directory: Dir.pwd + "/spec/examples/99999/outgoing", incoming_directory: Dir.pwd + "/spec/examples/99999/incoming", reply_directory: Dir.pwd + "/spec/examples/99999/incoming", archive_directory: Dir.pwd + "/spec/examples/99999/archive")
    #   @credit_service = Bankserv::CreditService.register(client_code: '12347', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 1, transmission_status: "L", transmission_number: "1", outgoing_directory: Dir.pwd + "/spec/examples/9999/outgoing", incoming_directory: Dir.pwd + "/spec/examples/9999/incoming", reply_directory: Dir.pwd + "/spec/examples/9999/incoming", archive_directory: Dir.pwd + "/spec/examples/9999/archive")
    #   Bankserv::EngineConfiguration.create!(interval_in_minutes: 15, input_directory: @tmpdir, output_directory: @tmpdir, archive_directory: @tmpdir)
    #   
    #   # test that engine can process different service types at once (generate 3 files with one run)
    #   # Bankserv::AccountHolderVerification.should_receive(:generate_reference_number).exactly(8).times.and_return("AHV67","AHV68","AHV69","AHV70","AHV71","AHV72","AHV73","AHV74")
    #   create_ahv_requests_scenario(@ahv_service)
    #   create_debit_requests_scenario(@debit_service)
    #   create_credit_requests_scenario(@credit_service)
    #   
    #   e = Bankserv::Engine.start
    #   # e.should_receive(:generate_input_file_name).and_return("harry.txt", "sally.txt", "molly.txt")
    #   # e.process!
    # end
    #   
    # it "should process ahv requests" do
    #   puts Dir.glob("#{@ahv_service.config[:outgoing_directory]}/INPUT*.txt").last
    #   # expected_string = File.open("#{Dir.pwd}/spec/examples/95345/outgoing/INPUT.120410144410.txt", "rb").read
    #   expected_string = File.open(Dir.glob("#{@ahv_service.config[:outgoing_directory]}/INPUT*.txt").last, "rb").read
    #   got_string = File.open(@tmpdir + '/harry.txt', "rb").read
    #   got_string.should == expected_string
    # end
    #   
    # it "should process debit requests" do
    #   expected_string = File.open("#{Dir.pwd}/spec/examples/99999/outgoing/INPUT.120411110604.txt", "rb").read
    #   got_string = File.open(@tmpdir + '/sally.txt', "rb").read
    #   got_string.should == expected_string
    # end
    #   
    # it "should process credit requests" do
    #   expected_string = File.open("#{Dir.pwd}/spec/examples/9999/outgoing/INPUT.120411124123.txt", "rb").read
    #   got_string = File.open(@tmpdir + '/molly.txt', "rb").read
    #   got_string.should == expected_string
    # end
  
  end
  
end