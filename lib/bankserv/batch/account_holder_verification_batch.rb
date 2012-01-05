module Bankserv
  
  class AccountHolderVerificationBatch < Batch
    
    after_save :set_batch_header, :set_batch_trailer
    
    def self.create_batches
      batch = self.new
      AccountHolderVerification.unprocessed.each do |ahv|
        batch.records.build(data: ahv.to_hash, type: ahv.record_type)
      end
      
      batch.records << batch.build_header
      batch.records << batch.build_trailer
      batch
    end
    
    def self.has_work?
      AccountHolderVerification.has_work?
    end
    
    def header
      records.select {|rec| rec.type == "header"}.first
    end
    
    def transactions
      records.select {|rec| !(["header", "trailer"].include? rec.type)  }
    end
    
    def trailer
      records.select {|rec| rec.type == "trailer"}.first
    end
    
    def build_header
      Record.new(type: "header", data: self.header_data)
    end
    
    def build_trailer
      Record.new(type: "trailer", data: self.trailer_data)
    end
    
    def header_data
      {
        rec_id: "30",
        rec_status: "T"
      }
    end
    
    def trailer_data
      {
        rec_id: "39",
        rec_status: "T"
      }
    end
    
    def hash_total
      sum = 0

      records.select {|rec| !(["header", "trailer"].include? rec.type)  }.map(&:data).each do |d|
        sum += d[:acc_no].to_i || 0
      end
      
      sum
    end
   
    private
    
    def set_batch_header
      header.data[:gen_no] = self.id
      header.save!
    end
    
    def set_batch_trailer
      trailer.data[:no_det_recs] = self.transactions.count
      trailer.data[:acc_total] = self.hash_total
      trailer.save!
    end
    
  end
  
end