FactoryGirl.define do
  
  factory :bank_account, :class => "Bankserv::BankAccount" do
    branch_code { Faker::Base::numerify('######') }
    account_number { Faker::Base::numerify('############') }
    account_type { 'savings' }
    initials { Faker::Name::first_name[0] }
    account_name { Faker::Name::last_name }
    id_number { Faker::Base::numerify('#############') }
    
    factory :external_bank_account do
      branch_code { (((1..9).to_a) - [6]).shuffle.first.to_s + Faker::Base::numerify('#####') }
    end
    
    factory :internal_bank_account do
      branch_code { Faker::Base::numerify('632005') }
    end
  end
  
  factory :ahv, :class => "Bankserv::AccountHolderVerification" do
    association :bank_account, :factory => :bank_account
    user_ref { Faker::Base::letterify('????????????') }
    status "new"
    
    factory :internal_ahv do
      internal true
      association :bank_account, :factory => :internal_bank_account
    end
  end
  
  factory :bankserv_request, :class => "Bankserv::AccountHolderVerification" do
    
    factory :ahv_bankserv_request do
      type 'ahv'
      data { {user_ref: Faker::Base::letterify('????????????')} }
    end
    
  end
  
  factory :debit, :class => "Bankserv::Debit" do
    
  end
  
  factory :credit, :class => "Bankserv::Credit" do
    
  end
  
  factory :document, :class => "Bankserv::Document" do
    processed false
    
    factory :output_document, :class => "Bankserv::OutputDocument" do
      type 'output'
      user_ref "1"
    end
    
    factory :input_document, :class => "Bankserv::InputDocument" do
      type 'input'
    end
    
    factory :reply_document, :class => "Bankserv::ReplyDocument" do
      type 'reply'
    end
    
    trait :processed do
      processed true
    end
    
    trait :output do
      type 'output'
    end
    
    trait :input do
      type 'input'
    end
    
  end
  
end