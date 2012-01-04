module Bankserv
  
  class AccountHolderVerification < ActiveRecord::Base
  
    def self.request(options)
      Request.create!(options)
    end
  end
  
end

