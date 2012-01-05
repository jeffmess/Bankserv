module Bankserv
  
  class Document < ActiveRecord::Base
    
    has_many :batches
    
    def self.has_work?
      AccountHolderVerificationBatch.has_work? || DebitBatch.has_work?
    end
    
    def self.create_jobs!
      return unless self.has_work?
      
      document = self.new
      document.batches << AccountHolderVerificationBatch.create_jobs!
      
      if AccountHolderVerificationBatch.has_work?
        AccountHolderVerificationBatch.create_jobs!
      end
      
    end
  
  end
  
end