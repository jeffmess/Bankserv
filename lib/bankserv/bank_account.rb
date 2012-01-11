module Bankserv
  
  class BankAccount < ActiveRecord::Base
    
    def self.extract_hash(options)
      options.reject{|k,v| not attribute_names.include?(k.to_s) }
    end
    
  end
  
end