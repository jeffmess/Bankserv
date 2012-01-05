module Bankserv
  
  class AccountHolderVerificationBatch < Batch
    
    before_save :decorate_records
    after_save :set_batch_header
    
    def self.create_batches
      batches = []
      
      if AccountHolderVerification.unprocessed.internal.count > 0
        batch = self.new
        batch.build_header
        AccountHolderVerification.unprocessed.internal.each{|ahv| batch.build_transaction(ahv)}
        batch.build_trailer
        batches << batch
      end
      
      if AccountHolderVerification.unprocessed.external.count > 0
        batch = self.new
        batch.build_header
        AccountHolderVerification.unprocessed.external.each{|ahv| batch.build_transaction(ahv)}
        batch.build_trailer
        batches << batch
      end
      
      batches
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
      self.records << Record.new(type: "header", data: self.header_data)
    end
    
    def build_trailer
      self.records << Record.new(type: "trailer", data: self.trailer_data)
    end
    
    def build_transaction(ahv)
      record_data = if ahv.external?
        Absa::H2h::Transmission::AccountHolderVerification.record_type('external_account_detail').template_options
      else
        Absa::H2h::Transmission::AccountHolderVerification.record_type('internal_account_detail').template_options
      end
        
      record_data.merge!(
        rec_status: "T",
        seq_no: transactions.count + 1,
        acc_no: ahv.bank_account.account_number,
        idno: ahv.bank_account.id_number,
        initials: ahv.bank_account.initials,
        surname: ahv.bank_account.account_name,
        user_ref: ahv.user_ref
      )
      
      record_data.merge!(branch_code: ahv.bank_account.branch_code) if ahv.external?
      
      self.records << Record.new(type: ahv.record_type, data: record_data)
    end
    
    def header_data
      defaults = Absa::H2h::Transmission::AccountHolderVerification.record_type('header').template_options
      params = {rec_status: "T"}
      
      defaults.merge(params)
    end
    
    def trailer_data
      defaults = Absa::H2h::Transmission::AccountHolderVerification.record_type('trailer').template_options
      params = {rec_status: "T"}
      defaults.merge(params)
    end
    
    def hash_total
      sum = 0

      records.select {|rec| !(["header", "trailer"].include? rec.type)  }.map(&:data).each do |d|
        sum += d[:acc_no].to_i || 0
      end
      
      sum
    end
   
    private
    
    def decorate_records
      set_batch_trailer
      
      records.each do |record|
        defaults = Absa::H2h::Transmission::AccountHolderVerification.record_type(record.type).template_options
        record.data = defaults.merge(record.data)
      end
      
      self.records.each{|rec| rec.save!}
    end
    
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