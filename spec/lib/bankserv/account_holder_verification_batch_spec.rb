require 'spec_helper'

describe Bankserv::AccountHolderVerificationBatch do
  
  context "Building an account holder verification batch" do
    
    before(:all) do
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
      Bankserv::AccountHolderVerificationBatch.has_work?.should be_true
    end 
    
    it "should create a batch with a header when the job begins" do
      batch = Bankserv::AccountHolderVerificationBatch.create_batches
      batch.save
      batch.header.data.should == {rec_id: "30", rec_status: "T", gen_no: batch.id}
    end
    
    it "should create a batch of transactions when the job begins" do
      batch = Bankserv::AccountHolderVerificationBatch.create_batches
      batch.save
      batch.transactions.first.type.should == "external_account_detail"
    end
    
    it "should create a batch with a trailer when the job begins" do
      batch = Bankserv::AccountHolderVerificationBatch.create_batches
      batch.save
      batch.trailer.data.should == {
        rec_id: "39", rec_status: "T", no_det_recs: 1, acc_total: @bank_hash[:account_number].to_i
      }
    end
  end
      
end
