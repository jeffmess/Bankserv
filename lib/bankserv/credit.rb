module Bankserv
  
  class Credit < ActiveRecord::Base
    extend Eft

    scope :unprocessed, where(processed: false)

    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
  end
  
end