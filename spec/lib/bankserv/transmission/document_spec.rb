require 'spec_helper'

describe Bankserv::Document do
  
  before(:all) do
    Bankserv::Document.delete_all
    Bankserv::Set.delete_all
    Bankserv::Record.delete_all
    Bankserv::AccountHolderVerification.delete_all
    
    ahv = Bankserv::AccountHolderVerification.new(
      bank_account: Bankserv::BankAccount.new(
        account_number: "2938423984",
        branch_code: "250255",
        account_type: 'savings',
        id_number: '0394543905',
        initials: "P",
        account_name: "Hendrik"
      ),
      user_ref: "34",
      internal: true
    )
    
    ahv.save!
    
    ahv = Bankserv::AccountHolderVerification.new(
      bank_account: Bankserv::BankAccount.new(
        account_number: "3948753475",
        branch_code: "253265",
        account_type: 'cheque',
        id_number: '9842928459485',
        initials: "S",
        account_name: "van der Merver"
      ),
      user_ref: "340",
      internal: true
    )
    
    ahv.save!
  end
  
  it "should build a new document" do
    
    puts Bankserv::AccountHolderVerification.last.inspect
    Bankserv::Document.create_documents!
    
    document = Bankserv::Document.last
    
    puts document.inspect
    puts document.sets.inspect
    
    document.sets.each do |set|
      puts set.records.to_yaml
    end
    
    hash = document.to_hash

    puts hash.inspect
        # 
        # puts hash.to_json
        # 
        # hash = hash.to_json
        # hash = JSON.parse(hash)
        # puts hash.inspect
    
    
    puts Absa::H2h::Transmission::Document.build(hash[:data])
    
  end
      
end
