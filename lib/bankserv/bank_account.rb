module Bankserv
  
  class BankAccount < ActiveRecord::Base
    
    def self.extract_hash(options)
      return options.reject{|k,v| not [:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials].include?(k) }
    end
    
  end
  
end