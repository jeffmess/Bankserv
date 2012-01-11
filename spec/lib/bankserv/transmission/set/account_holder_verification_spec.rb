require 'spec_helper'

describe Bankserv::Transmission::UserSet::AccountHolderVerification do
  include Helpers
  
  before(:all) do
    tear_it_down
    create(:configuration)
    
    @ahv_list = []
    @ahv_list << create_list(:internal_ahv, 2)
    @ahv_list << create_list(:ahv, 3)
  end
  
  it "should return true when a batch needs to be processed" do
    Bankserv::Transmission::UserSet::AccountHolderVerification.has_work?.should be_true
  end
  
  it "should place internal and external account holder verifications into separate user sets" do
    sets = Bankserv::Transmission::UserSet::AccountHolderVerification.generate
    
    sets.count.should == 2
    sets.first.transactions.count.should == 2
    sets.last.transactions.count.should == 3
  end
  
  context "Building an account holder verification set" do
    
    before(:each) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::AccountHolderVerification.delete_all
      
      @ahv_list = create_list(:internal_ahv, 4)
    end
    
    context "creating a header" do
      
      before(:each) do
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
        @set.save
      end
      
      it "should store the record id" do
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
        @set = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
        @set.save
      end
      
      it "should store the record id" do
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
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
      batch.save
      batch.transactions.first.record_type.should == "internal_account_detail"
    end
    
  end
      
end
