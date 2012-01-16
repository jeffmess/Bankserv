module Bankserv
  
  class Debit < ActiveRecord::Base
    extend Eft
    
    scope :unprocessed, where(processed: false)
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    def standard?
      self.record_type == "standard"
    end
    
    def user_reference
      if self.standard?
        "#{Configuration.client_abbreviated_name[0..9]}#{user_ref}"
      else
        "#{Configuration.client_abbreviated_name[0..9]}#{user_ref}"
      end
    end
    
    def contra_bank_details
      if self.standard?
        Debit.where(record_type: "contra", batch_id: self.batch_id, processed: false).first.bank_account
      else
        self.bank_account
      end
    end
  end
  
end
