module Bankserv

  class NotifyMeStatement < ActiveRecord::Base
    
    has_many :notify_me_transactions, :foreign_key => 'bankserv_notify_me_statement_id'
  
    def self.store(file)
      options = Absa::NotifyMe::XmlStatement.file_to_hash(file)
      
      raise "Expected a document set" unless options[:type] == "document"
      
      client_code = options[:data][:data][0][:data][:client_code]
    
      statement = new
      statement.client_code = client_code
      statement.data = options
      statement.save!
      statement
    end
  
    def process!
      raise "Document already processed" if processed?
    
      recon_account_detail_records.each do |record|
        Bankserv::NotifyMeTransaction.create! data: record[:data], client_code: client_code, bankserv_notify_me_statement_id: id
      end
    
      self.processed = true
      self.save
    end
  
    def recon_transmission_data
      data[:data][:data]
    end
  
    def recon_account_detail_records
      recon_transmission_data.select{|item| item[:type] == 'detail'}
    end
  
  end
  
end
