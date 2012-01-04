module Bankserv
  module AccountHolderVerification
  
    def self.request(options)
      if options[:branch_code] == '632005'
        BankservInternalAccountDetail.create! options
      else
        BankservExternalAccountDetail.create! options
      end
        
      true
    end
    
    def self.unprocessed
      BankservInternalAccountDetail 
    end
  
  end
  
  class BankservInternalAccountDetail < ActiveRecord::Base
    
  end
  
  class BankservExternalAccountDetail < ActiveRecord::Base
    
  end
end

