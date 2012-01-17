module Bankserv
  
  class BankAccount < ActiveRecord::Base
    
    def account_type_id
      if self.account_type.to_i != 0
        self.account_type.to_s
      else
        { "current" => "1",
        "savings" => "2",
        "transmission" => "3",
        "bond" => "4",
        "subscription" => "6" }[self.account_type.downcase]
      end
    end
    
  end
  
end