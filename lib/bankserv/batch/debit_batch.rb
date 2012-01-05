module Bankserv
  
  class DebitBatch < Batch
    
    def self.create_batches
      batch = self.new
      
      Debit.unprocessed.group_by(&:set_id).each do |set_id, debit_order|
        
      end
    end
    
    def self.has_work?
      Debit.has_work?
    end
    
  end
  
end