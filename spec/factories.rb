FactoryGirl.define do
  
  factory :bank_account, :class => "Bankserv::BankAccount" do
    branch_code { Faker::Base::numerify('######') }
    account_number { Faker::Base::numerify('############') }
    account_type { 'savings' }
    initials { Faker::Name::first_name[0] }
    account_name { Faker::Name::last_name }
    id_number { Faker::Base::numerify('#############') }
    
    factory :internal_bank_account do
      branch_code Faker::Base::numerify('632005')
    end
  end
  
  factory :ahv, :class => "Bankserv::AccountHolderVerification" do
    association :bank_account, :factory => :bank_account
    user_ref { Faker::Base::letterify('????????????') }
    
    factory :internal_ahv do
      internal true
      association :bank_account, :factory => :internal_bank_account
    end
  end
  
end