module Bankserv
  
  class Debit < ActiveRecord::Base
    extend Eft
    
    inheritance_column = :_type_disabled
    
    scope :unprocessed, where(processed: false)
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
  end
  
end
