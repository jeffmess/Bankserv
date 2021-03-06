module Bankserv

  class Statement < ActiveRecord::Base
    
    has_many :transactions, :foreign_key => 'bankserv_statement_id'
  
    def self.store(string)
      options = Absa::Esd::Transmission::Document.hash_from_s(string)
      
      raise "Expected a document set" unless options[:type] == "document"
    
      client_code = options[:data][0][:data][0][:data][:client_code]
    
      statement = new
      statement.client_code = client_code
      statement.data = options
      statement.save!
      statement
    end
  
    def process!
      raise "Document already processed" if processed?
    
      count = 1
      account_number = recon_account_detail_records.first[:data][:account_number]

      recon_account_detail_records.each do |record|
        next if record[:data][:transaction_description] == "GEEN/NO TRAN"

        if record[:data][:account_number] != account_number
          account_number = record[:data][:account_number]
          count = 1
        end

        Bankserv::Transaction.create! data: record[:data].merge(transaction_number_for_day: count), client_code: client_code, bankserv_statement_id: id
        
        count += 1
      end
    
      self.processed = true
      self.save
    end
  
    def recon_transmission_data
      data[:data][0][:data]
    end
  
    def recon_account_data
      recon_transmission_data[1][:data]
    end
  
    def recon_account_detail_records
      recon_account_data.select{|item| item[:type] == 'detail'}
    end
  
  end
  
end
