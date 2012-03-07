module Bankserv
  
  class Transaction < ActiveRecord::Base
    
    belongs_to :statement, :foreign_key => 'bankserv_statement_id'
  
    serialize :data
    
    scope :unprocessed, where(processed: false)
    
    def self.for_client_code(client_code)
      where(client_code: client_code)
    end
    
  end
  
end