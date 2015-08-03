require 'spec_helper'

describe Bankserv::InputDocument do
  include Helpers
  
  context "building a transmission document containing two account holder verification requests" do

    before(:each) do
      tear_it_down
      bankserv_service = Bankserv::AHVService.register(client_code: '2236', internal_branch_code: '632005', department_code: "000001", client_name: "TEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "L", transmission_number: "0", internal: false)
  
      ahv_attributes = {
        bank_account: {
          account_number: "1094402524",
          branch_code: "250255",
          account_type: 'savings',
          id_number: '6703085829086',
          initials: "M",
          account_name: "CHAUKE"
        },
        user_ref: "AHV1"
      }
    
      bankserv_service.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
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
        user_ref: "AHV2"
      }
    
      bankserv_service.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
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
        user_ref: "AHV3"
      }
    
      bankserv_service.request(type: 'ahv', data: ahv_attributes)
      ahv = Bankserv::AccountHolderVerification.last
      ahv.internal = true
      ahv.save!
    
      t = Time.local(2009, 7, 3, 10, 5, 0)
      Timecop.travel(t)
  
      Bankserv::InputDocument.generate!(bankserv_service)
    
      @document = Bankserv::Document.last
    end
  
    it "should mark the document as an input transmission" do
      @document.type.should == "input"
    end

    it "should match the user reference with document id" do
      @document.user_ref.should == @document.id.to_s
      @document.set.header.data[:th_for_use_of_ld_user].should == @document.id.to_s
    end

    it "should build a new document" do
      hash = @document.to_hash
    
      string = File.open("./spec/examples/ahv_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      options[:data].first[:data][:th_for_use_of_ld_user] = @document.user_ref
      hash.should == options
    end
  
    it "should be able to mark a document as processed" do
      @document.mark_processed!
      @document.processed.should be_truthy
    end

    it "should mark the ahv services internal status to true" do
      Bankserv::AHVService.active.first.config[:internal].should be_truthy
    end

    it "should not build a document if no sets could be generated" do
      Bankserv::Transmission::UserSet::Document.all.count.should == 1
      Bankserv::InputDocument.generate!(Bankserv::AHVService.active.first)
      Bankserv::Transmission::UserSet::Document.all.count.should == 1
    end
  end
  
  context "building a transmission document two batches of debit order requests" do
    before(:all) do
      tear_it_down  
      @bankserv_service = Bankserv::DebitService.register(client_code: '10', client_name: "LDC USER 10 AFRICA (PTY)", client_abbreviated_name: 'ALIMITTST', user_code: "9534", generation_number: 37, transmission_status: "T", transmission_number: "621")
      
      t = Time.local(2004, 5, 24, 10, 5, 0)
      Timecop.travel(t)
      
      debit = @bankserv_service.request({
        type: 'debit',
        data: {
          type_of_service: "CORPSSV",
          batches: [{
            credit: {
              account_number: "4053538939", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 16028000, user_ref: "1040524 08", action_date: Date.today
            },
            debit: [
              { account_number: '1019611899', branch_code: "632005", account_type: "1", id_number: '', amount: 1000,    action_date: Date.today, account_name: "HENNIE DU TOIT",  user_ref: 'SPP   1040524 01'},
              { account_number: '1019801892', branch_code: "632005", account_type: "1", id_number: '', amount: 2000,    action_date: Date.today, account_name: "TYRONE DREYDEN",  user_ref: "SPP   1040524 02"},
              { account_number: '1021131896', branch_code: "632005", account_type: "1", id_number: '', amount: 3000,    action_date: Date.today, account_name: "KEITH MEIKLEJOHN AND MORE THAN 30 CHARACTERS",user_ref: "SPP   1040524 03"},
              { account_number: '1022131890', branch_code: "632005", account_type: "1", id_number: '', amount: 4000,    action_date: Date.today, account_name: "CHRISTO SPIES",   user_ref: "SPP   1040524 04"},
              { account_number: '1057401890', branch_code: "632005", account_type: "1", id_number: '', amount: 6005000, action_date: Date.today, account_name: "DENISE RETIEF",   user_ref: "SPP   1040524 05"}, 
              { account_number: '18000010304',branch_code: "632005", account_type: "1", id_number: '', amount: 3006000, action_date: Date.today, account_name: "PETER HAUPT",     user_ref: "SPP   1040524 06"},  
              { account_number: '1020861726', branch_code: "632005", account_type: "1", id_number: '', amount: 7007000, action_date: Date.today, account_name: "HADLEY RAW",      user_ref: "SPP   1040524 07"}    
            ]
          }, {
            credit: {
              account_number: "1004651894", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "ALIMITTST", amount: 4280000, user_ref: "2040525 08", action_date: Date.tomorrow
            },
            debit: [
              { account_number: '1006221897', branch_code: "632005", account_type: "1", id_number: '', amount: 10000,  action_date: Date.tomorrow, account_name: "HENNIE DU TOIT",  user_ref: 'SPP   2040525 01'},
              { account_number: '1006241898', branch_code: "632005", account_type: "1", id_number: '', amount: 20000,  action_date: Date.tomorrow, account_name: "TYRONE DREYDEN",  user_ref: "SPP   2040525 02"},
              { account_number: '1009831891', branch_code: "632005", account_type: "1", id_number: '', amount: 4030000,action_date: Date.tomorrow, account_name: "KEITH MEIKLEJOHN AND MORE THAN 30 CHARACTERS",user_ref: "SPP   2040525 03"},
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
      Bankserv::InputDocument.generate!(@bankserv_service)
      
      document = Bankserv::Document.last
      hash = document.to_hash

      hash[:data].first[:data][:th_for_use_of_ld_user] = "621"
      
      string = File.open("./spec/examples/debit_eft_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options
    end
  
  end
  
  context "building a transmission document credit order requests" do
    before(:each) do
      tear_it_down

      t = Time.local(2008, 8, 8, 10, 5, 0)
      Timecop.travel(t)
      
      @bankserv_service = Bankserv::CreditService.register(client_code: '986', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 3446, sequence_number: 78, sequence_number_updated_at: Time.now, transmission_status: "L", transmission_number: "846")
      create_credit_request(@bankserv_service)
    end
    
    it "should build a new document with a credit set" do        
      Bankserv::InputDocument.generate!(@bankserv_service)
      
      document = Bankserv::Document.last
      hash = document.to_hash

      hash[:data].first[:data][:th_for_use_of_ld_user] = "846"
      
      string = File.open("./spec/examples/credit_eft_input.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options
    end
  end

  context "Create an input file that contains an transaction with a non-standard homing account number" do

    before(:each) do
      tear_it_down
      t = Time.local(2015, 5, 30, 10, 5, 0)
      Timecop.travel(t)
      @cs = Bankserv::CreditService.register(client_code: '4136', client_name: "RENTAL CONNECT PTY LTD", client_abbreviated_name: 'RAWSONPROP', user_code: "A855", generation_number: 3446, transmission_status: "L", transmission_number: "846", sequence_number: 1, sequence_number_updated_at: Date.yesterday)

      @file_contents = File.open("./spec/examples/input/wrong_input_file", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)

      options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'input')
      options[:data].each do |entry|
        if entry[:data].count == 4
          c = entry[:data].map {|x| x[:data]}
          account_num = (c[1][:homing_account_number] if c[1][:homing_account_number] != "0") || (c[1][:non_standard_homing_account_number] if c[1][:non_standard_homing_account_number] != "0")
          request = Bankserv::Request.create!({
            type: "credit",
            data: {
              :type_of_service=>"BATCH", 
              :batches=>[{
                :debit=>{:account_number=>c[2][:homing_account_number], :id_number=>"", :initials=>"", :account_name=>c[2][:homing_account_name], :branch_code=>c[2][:homing_branch], :account_type=>"cheque", :amount=>c[2][:amount], :user_ref=>c[2][:user_ref].gsub("RAWSONPROPCONTRA", ""), :action_date=>"2015-05-30".to_date}, 
                :credit=>{:account_number=>account_num, :id_number=>"", :initials=>"", :account_name=>c[1][:homing_account_name], :branch_code=>c[1][:homing_branch], :account_type=>"cheque", :amount=>c[1][:amount], :user_ref=>c[1][:user_ref].gsub("RAWSONPROP", ""), :action_date=>"2015-05-30".to_date}
              }]
            }
          })

          request.service_id = @cs.id
          request.save!
        end
      end

      @cs.reload
      @cs.config[:sequence_number] = 1
      @cs.save!

      Bankserv::InputDocument.generate!(@cs)
    end

    it 'should create 43 bankserv requests' do
      Bankserv::Request.all.count.should == 43
    end

    it 'should build a correct input file' do
      document = Bankserv::Document.last
      hash = document.to_hash

      hash[:data].first[:data][:th_for_use_of_ld_user] = "4908"
      
      string = File.open("./spec/examples/input/correct_input_file", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options

    end

    it 'should compare the all entries for both files and they should match' do
      document = Bankserv::Document.last
      hash = document.to_hash

      hash[:data].first[:data][:th_for_use_of_ld_user] = "4908"
      
      string = File.open("./spec/examples/input/correct_input_file", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')

      hash[:data].should == options[:data]

    end

    it 'should generate the file without any errors' do
      document = Bankserv::Document.last

      lambda {Absa::H2h::Transmission::Document.build([document.to_hash])}.should_not raise_error(Exception)

      # file_name = generate_input_file_name(document)
      
      # File.open("#{@service.config[:outgoing_directory]}/#{file_name}", 'w') { |f|
      #   f.write transmission
      # }
      # @logs[:input_files] << "Input Document File created. File name: #{file_name}"
      # true

    end
  
  end

  context "Create an input file that contains debit order transactions" do
    
    before(:all) do
      tear_it_down  
      @bankserv_service = Bankserv::CreditService.register(client_code: '986', client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', user_code: "9999", generation_number: 3446, sequence_number: 78, sequence_number_updated_at: Time.now, transmission_status: "L", transmission_number: "846")
      
      t = Time.local(2004, 5, 24, 10, 5, 0)
      Timecop.travel(t)
      
      @file_contents = File.open("./spec/examples/input/correct_debit_order_input_file", "rb").read
      @input_document = Bankserv::InputDocument.store(@file_contents)
      
      options = Absa::H2h::Transmission::Document.hash_from_s(@file_contents, 'input')
      options[:data].each do |entry|
        if entry[:data].count == 4
          c = entry[:data].map {|x| x[:data]}
          account_num = (c[1][:homing_account_number] if c[1][:homing_account_number] != "0") || (c[1][:non_standard_homing_account_number] if c[1][:non_standard_homing_account_number] != "0")
          request = Bankserv::Request.create!({
            type: "debit",
            data: {
              :type_of_service=>"TWO DAY", 
              :batches=>[{
                :debit=>{:account_number=>c[2][:homing_account_number], :id_number=>"", :initials=>"", :account_name=>c[2][:homing_account_name], :branch_code=>c[2][:homing_branch], :account_type=>"cheque", :amount=>c[2][:amount], :user_ref=>c[2][:user_ref].gsub("RAWSONPROPCONTRA", ""), :action_date=>"2015-05-30".to_date}, 
                :credit=>{:account_number=>account_num, :id_number=>"", :initials=>"", :account_name=>c[1][:homing_account_name], :branch_code=>c[1][:homing_branch], :account_type=>"cheque", :amount=>c[1][:amount], :user_ref=>c[1][:user_ref].gsub("RAWSONPROP", ""), :action_date=>"2015-05-30".to_date}
              }]
            }
          })

          request.service_id = @cs.id
          request.save!
        end
      end
    end

    it 'should create 5 bankserv requests' do
      Bankserv::Request.all.count.should == 5
    end

    it 'should build a correct input file' do
      puts option.inspect
      document = Bankserv::Document.last
      hash = document.to_hash

      hash[:data].first[:data][:th_for_use_of_ld_user] = "4908"
      
      string = File.open("./spec/examples/input/correct_debit_order_input_file", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      hash.should == options

    end

  end


end