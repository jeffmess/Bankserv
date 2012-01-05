module Bankserv
  
  class AccountHolderVerificationBatch < Batch
    
    def self.create_batches
      batch = self.new
      AccountHolderVerification.unprocessed.each do |ahv|
        batch.records << Record.new(data: ahv.to_hash, type: ahv.record_type)
      end
      
      batch.records << batch.build_header
      batch.records << batch.build_trailer
      batch
    end
    
    def self.has_work?
      AccountHolderVerification.has_work?
    end
    
    def build_header
      Record.new(type: "header", data: self.header)
    end
    
    def build_trailer
      Record.new(type: "trailer", data: self.trailer)
    end
    
    def header
      {
        rec_id: "30",
        rec_status: "T",
        gen_no: self.id
      }
    end
    
    def trailer
      {
        rec_id: "39",
        rec_status: "T",
        no_det_recs: self.batches.count,
        acc_total: self.hash_total
      }
    end
    
    def hash_total
      batches.map(&:amount).map(&:to_i).inject(:+)
    end
    
  end
  
end