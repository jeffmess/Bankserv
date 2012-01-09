require 'spec_helper'

describe Bankserv::Document do
  
  context "building a transmission document containing two account holder verification requests" do
  
    before(:all) do
      Bankserv::Document.delete_all
      Bankserv::Set.delete_all
      Bankserv::Record.delete_all
      Bankserv::AccountHolderVerification.delete_all
    
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "1094402524",
          branch_code: "250255",
          account_type: 'savings',
          id_number: '6703085829086',
          initials: "M",
          account_name: "CHAUKE"
        ),
        user_ref: "149505000060000223600000000000",
        internal: true
      )
    
      ahv.save!
    
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2968474669",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '6103120039082',
          initials: "A",
          account_name: "VAN MOLENDORF"
        ),
        user_ref: "198841000060000223600000000000",
        internal: true
      )
    
      ahv.save!
      
      ahv = Bankserv::AccountHolderVerification.new(
        bank_account: Bankserv::BankAccount.new(
          account_number: "2492008177",
          branch_code: "253265",
          account_type: 'cheque',
          id_number: '8801261110087',
          initials: "U",
          account_name: "NKWEBA"
        ),
        user_ref: "149205000060000223600000000000",
        internal: true
      )
    
      ahv.save!
    end
  
    it "should build a new document" do
      t = Time.local(2009, 7, 3, 10, 5, 0)
      Timecop.travel(t)
    
      Bankserv::Document.generate!(
        mode: "L", 
        client_code: "2236", 
        client_name: "TEST", 
        transmission_number: "0", 
        th_for_use_of_ld_user: ""
      )
    
      document = Bankserv::Document.last
      hash = document.to_hash
      
      string = File.open("./spec/examples/ahv_input_file.txt", "rb").read
      options = Absa::H2h::Transmission::Document.hash_from_s(string)
      
      hash.should == options
    end
  end
      
end
