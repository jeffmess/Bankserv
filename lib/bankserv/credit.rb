module Bankserv
  
  class Credit < ActiveRecord::Base
    extend Eft

    serialize :response
    scope :unprocessed, where(status: "new")

    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    def self.bankserv_service
      Bankserv::CreditService.where(active: true).last
    end
    
    def bankserv_service
      Bankserv::Credit.bankserv_service
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def new?
      status == "new"
    end
    
    def pending?
      status == "pending"
    end

    def pending!
      self.status = "pending"
      save!
    end
    
    def error?
      status == "error"
    end
    
    def completed?
      status == "completed"
    end

    def accepted?
      status == "accepted"
    end

    def accept!
      self.status = "accepted"
      save!
    end

    def renew!
      self.status = "new"
      save!
    end
    
    def standard?
      record_type == "standard"
    end
    
    def contra?
      record_type == "contra"
    end
    
    def formatted_user_ref
      abbreviated_name = bankserv_service.config[:client_abbreviated_name]
      
      if contra?
        bankserv_service.config[:client_abbreviated_name]
        abbreviated_name.ljust(10, ' ') << "CONTRA#{user_ref}"
      else
        abbreviated_name.ljust(10, ' ') << user_ref
      end
    end
    
    def contra_bank_details
      if self.standard?
        Credit.where(record_type: "contra", batch_id: self.batch_id, status: "new").first.bank_account
      else
        self.bank_account
      end
    end
  end
end