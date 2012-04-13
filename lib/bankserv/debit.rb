module Bankserv
  
  class Debit < ActiveRecord::Base
    extend Eft
    
    serialize :response
    scope :unprocessed, where(status: "new")
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    after_create :generate_internal_user_ref
    
    def self.bankserv_service
      Bankserv::DebitService.where(active: true).last
    end
    
    def bankserv_service
      Bankserv::Debit.bankserv_service
    end
    
    def generate_internal_user_ref
      self.internal_user_ref = "DEBIT#{id}"
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
        abbreviated_name.ljust(10, ' ') << "CONTRA#{user_ref}"
      else
        abbreviated_name.ljust(10, ' ') << user_ref
      end
    end
    
    def contra_bank_details
      if self.standard?
        Debit.where(record_type: "contra", batch_id: self.batch_id, status: "new").first.bank_account
      else
        self.bank_account
      end
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.for_internal_reference(reference)
      self.where(:internal_user_ref => reference)
    end
    
    def process_response(data)
      save_data = if data[:response_status] == 'unpaid'
        {
          rejection_reason_description: Absa::H2h::Eft::RejectionCode.reason_for_code(data[:rejection_reason]),
          rejection_reason: data[:rejection_reason],
          rejection_qualifier_description: Absa::H2h::Eft::RejectionCode.qualifier_for_code(data[:rejection_qualifier]),
          rejection_qualifier: data[:rejection_qualifier]
        }
      elsif data[:response_status] == 'redirect'
        data.only([:new_homing_branch, :new_homing_account_number, :new_homing_account_type])
      end
      
      self.response = save_data
      self.status = data[:response_status]
      self.save!
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
    
    def unpaid?
      status == "unpaid"
    end
    
    def redirect?
      status == "redirect"
    end
  end
  
end
