require 'spec_helper'

describe Bankserv::Transmission::UserSet::AccountHolderVerification do
  include Helpers
  
  before(:all) do
    tear_it_down
    ahv_service = Bankserv::AHVService.register(client_code: '12345', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "T", transmission_number: "1", internal: true)
    
    @ahv_list = [
      ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      ahv_service.request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
      ahv_service.request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
      ahv_service.request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
    ]
    
    @ahv_list = Bankserv::AccountHolderVerification.all
  end
  
  it "should report when there are account holder verification requests that need to be processed" do
    Bankserv::Transmission::UserSet::AccountHolderVerification.has_test_work?.should be_truthy
  end

  it "should process the external account holder verifications" do
    sets = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T", internal: false)

    sets.count.should == 1
    sets.first.transactions.count.should == 3
  end

  it "should process the internal account holder verifications" do
    sets = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T", internal: true)

    sets.count.should == 1
    sets.first.transactions.count.should == 2
  end
  
  context "Building an account holder verification set" do
    
    before(:each) do
      tear_it_down
      ahv_service = Bankserv::AHVService.register(client_code: '12345', internal_branch_code: '632005', department_code: "506", client_name: "TESTTEST", client_abbreviated_name: 'TESTTEST', generation_number: 1, transmission_status: "T", transmission_number: "1", internal: false)
    
      @ahv_list = [
        ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        ahv_service.request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      ]
      
      @ahv_list = Bankserv::AccountHolderVerification.all
    end
    
    context "creating a header" do
      
      before(:each) do
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T", internal: true).first
        @set.save
      end
      
      it "should store the record id 030" do
        @set.header.data[:rec_id].should == "030"
      end
      
      it "should store the record status" do
        @set.header.data[:rec_status].should == "T"
      end
      
      it "should store the generation number" do
        @set.header.data.has_key?(:gen_no).should be_truthy
      end
      
      it "should store the specified department code" do
        @set.header.data.has_key?(:dept_code).should be_truthy
        @set.header.data[:dept_code].should == "AHVINT"
      end      
    end
    
    context "creating a trailer" do
      
      before(:each) do
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T", internal: true).first
        @set.save
      end
      
      it "should store the record id 039" do
        @set.trailer.data[:rec_id].should == "039"
      end
      
      it "should store the record status" do
        @set.trailer.data[:rec_status].should == "T"
      end
      
      it "should store the number of records in the set" do
        @set.trailer.data[:no_det_recs].should == "4"
      end
      
      it "should store the sum of the transaction account numbers" do        
        sum = 0
        @ahv_list.each{|ahv| sum += ahv.bank_account.account_number.to_i}
        
        @set.trailer.data[:acc_total].should == sum.to_s
      end
    end
    
    it "should create a batch of transactions when the job begins" do
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T", internal: true).first
      batch.save
      batch.transactions.first.record_type.should == "internal_account_detail"
    end
    
  end
      
end
