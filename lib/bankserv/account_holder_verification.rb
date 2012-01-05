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
      ba_options = options.reject{|k,v| not [:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials].include?(k) }
      options = options.reject{|k,v| [:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials].include?(k) }
      is_internal = ba_options[:branch_code] == "632005"
      
      self.create!(bank_account: BankAccount.new(ba_options), user_ref: options[:user_ref], internal: is_internal)
    end
    
    def self.has_work?
      return true unless unprocessed.empty?
      false
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

