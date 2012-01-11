module Bankserv
  
  class AccountHolderVerification < ActiveRecord::Base
    
    self.inheritance_column = :_type_disabled
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    
    scope :unprocessed, where(processed: false)
    scope :internal, where(internal: true)
    scope :external, where(internal: false)
  
    def self.request(options)
      Request.create!(options)
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.build!(options)
      bank_account = BankAccount.new(options[:bank_account])
      is_internal = bank_account.branch_code == "632005"
      
      self.create!(bank_account: bank_account, user_ref: options[:user_ref], internal: is_internal)
    end
    
    # instance methods
    
    def record_type
      internal? ? "internal_account_detail" : "external_account_detail"
    end
    
    def internal?
      internal == true
    end
    
    def external?
      !internal?
    end
    
  end
  
end

