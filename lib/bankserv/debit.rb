module Bankserv
  
  class Debit < ActiveRecord::Base
    extend Eft
    
    scope :unprocessed, where(processed: false)
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    
    def standard?
      self.record_type == "standard"
    end
    
    def user_reference
      if self.standard?
        "#{bank_account.account_name[0..9]}#{user_ref}"
      else
        "#{bank_account.account_name[0..9]}CONTRA#{user_ref}"
      end
    end
  end
  
end
