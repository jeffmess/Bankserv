require 'spec_helper'

describe Bankserv::Transmission::UserSet::AccountHolderVerification do
  
  context "Building an account holder verification batch" do
    
    before(:all) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::AccountHolderVerification.delete_all
      
      @bank_hash = {
        account_number: "2938423984",
        branch_code: "250255",
        account_type: 'savings',
        id_number: '0394543905',
        initials: "P",
        account_name: "Hendrik"
      }
    
      @hash = {
        type: 'ahv',
        data: {user_ref: "34"}.merge(@bank_hash)
      }
      Bankserv::AccountHolderVerification.request(@hash)
    end
    
    it "should return true when a batch needs to be processed" do
      Bankserv::Transmission::UserSet::AccountHolderVerification.has_work?.should be_true
    end 
    
    it "should create a batch with a header when the job begins" do
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
      batch.save
      batch.header.data.should == {
        rec_id: "030", 
        rec_status: "T", 
        gen_no: batch.id.to_s,
        dept_code: "1"
      }
    end
    
    it "should create a batch of transactions when the job begins" do
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
      batch.save
      batch.transactions.first.record_type.should == "external_account_detail"
    end
    
    it "should create a batch with a trailer when the job begins" do
      Bankserv::AccountHolderVerification.unprocessed.send(:internal).inspect
      
      batch = Bankserv::Transmission::UserSet::AccountHolderVerification.generate.first
      batch.save
      
      batch.trailer.data.should == {
        rec_id: "039", 
        rec_status: "T", 
        no_det_recs: 1.to_s, 
        acc_total: @bank_hash[:account_number]
      }
      
    end
  end
      
end
