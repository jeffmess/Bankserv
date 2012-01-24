require 'spec_helper'

describe Bankserv::Transmission::UserSet::AccountHolderVerification do
  include Helpers
  
  before(:all) do
    tear_it_down
    create(:configuration)
    
    @ahv_list = [
      Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
      Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
      Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:ahv).merge(bank_account: attributes_for(:external_bank_account))),
    ]
    
    @ahv_list = Bankserv::AccountHolderVerification.all
  end
  
  it "should report when there are account holder verification requests that need to be processed" do
    Bankserv::Transmission::UserSet::AccountHolderVerification.has_test_work?.should be_true
  end
  
  it "should place internal and external account holder verifications into separate user sets" do
    sets = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T")
    
    sets.count.should == 2
    sets.first.transactions.count.should == 2
    sets.last.transactions.count.should == 3
  end
  
  context "Building an account holder verification set" do
    
    before(:each) do
      tear_it_down
      create(:configuration)
    
      @ahv_list = [
        Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
        Bankserv::AccountHolderVerification.test_request(type: 'ahv', data: attributes_for(:internal_ahv).merge(bank_account: attributes_for(:internal_bank_account))),
      ]
      
      @ahv_list = Bankserv::AccountHolderVerification.all
    end
    
    context "creating a header" do
      
      before(:each) do
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T").first
        @set.save
      end
      
      it "should store the record id 030" do
        @set.header.data[:rec_id].should == "030"
      end
      
      it "should store the record status" do
        @set.header.data[:rec_status].should == "T"
      end
      
      it "should store the generation number" do
        @set.header.data.has_key?(:gen_no).should be_true
      end
      
      it "should store the specified department code" do
        @set.header.data.has_key?(:dept_code).should be_true
      end      
    end
    
    context "creating a trailer" do
      
      before(:each) do
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T").first
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
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate(rec_status: "T").first
      batch.save
      batch.transactions.first.record_type.should == "internal_account_detail"
    end
    
  end
      
end
