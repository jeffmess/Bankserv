module Bankserv
  
  class Batch < ActiveRecord::Base
    
    belongs_to :document
    has_many :records
    
  end
  
  class AccountHolderVerificationBatch < Batch
    
    scope unprocessed, where(processed: false)
    
    def self.create_batches
      batch = self.new
      AccountHolderVerification.unprocessed.each do |ahv|
        batch.records << Record.new(data: ahv.data, type: ahv.record_type)
      end
      
      batch.records << batch.build_header
      batch.records << batch.build_trailer
      batch
    end
    
    def self.has_work?
      AccountHolderVerification.has_work?
    end
    
    def build_header
      Record.new(type: "header", data: self.data)
    end
    
    def build_trailer
      
    end
    
    def data
      
      {
        rec_id: "30",
        rec_status: "T",
        gen_no: self.id
      }
      
    end
    
  end
  
end