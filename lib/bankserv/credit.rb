module Bankserv
  
  class Credit < ActiveRecord::Base
    extend Eft

    scope :unprocessed, where(processed: false)

    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    after_create :generate_internal_user_ref
    
    def generate_internal_user_ref
      self.internal_user_ref = "CREDIT#{id}"
      save!
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.for_internal_reference(reference)
      self.where(:internal_user_ref => reference)
    end
    
    def new?
      status == "new"
    end
    
    def pending?
      status == "pending"
    end
    
    def error?
      status == "error"
    end
    
    def completed?
      status == "completed"
    end
    
    def standard?
      self.record_type == "standard"
    end
    
    def formatted_user_ref
      if self.standard?
        "#{Configuration.client_abbreviated_name[0..9]}#{user_ref}"
      else
        "#{Configuration.client_abbreviated_name[0..9]}#{user_ref}"
      end
    end
    
    def contra_bank_details
      if self.standard?
        Credit.where(record_type: "contra", batch_id: self.batch_id, processed: false).first.bank_account
      else
        self.bank_account
      end
    end
    
  end
  
end