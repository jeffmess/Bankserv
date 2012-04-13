module Bankserv
  
  class Credit < ActiveRecord::Base
    extend Eft

    serialize :response
    scope :unprocessed, where(status: "new")

    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    after_create :generate_internal_user_ref
    
    def self.request(options = {})
      raise "Not registered as Bankserv Service" unless bankserv_service
      options.merge!(type: 'credit')
      Request.create!(options)
    end
    
    def self.test_request(options = {})
      raise "Not registered as Bankserv Service" unless bankserv_service
      options.merge!(type: 'credit')
      Request.create!(options.merge(test: true))
    end
    
    def self.bankserv_service
      Bankserv::Service.where(active: true, type: 'credit').last
    end
    
    def bankserv_service
      Bankserv::Credit.bankserv_service
    end
    
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