module Bankserv
  
  class AccountHolderVerification < ActiveRecord::Base
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    
    scope :unprocessed, where(processed: false)
  
    def self.request(options)
      Request.create!(options)
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.build!(options)
      ba_options = options.reject{|k,v| not [:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials].include?(k) }
      options = options.reject{|k,v| [:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials].include?(k) }
      
      self.create!(bank_account: BankAccount.new(ba_options), user_ref: options[:user_ref])
    end
    
    def self.has_work?
      return true unless unprocessed.empty?
      false
    end
    
    # instance methods
    
    def record_type
      bank_account.branch_code == "632005" ? "internal_account_detail" : "external_account_detail"
    end
    
    def internal?
      record_type == "internal_account_detail"
    end
    
    def external?
      !internal?
    end
    
    def to_hash
      account_detail = if external?
        Absa::H2h::Transmission::AccountHolderVerification.record_type('external_account_detail').template_options
      else
        Absa::H2h::Transmission::AccountHolderVerification.record_type('internal_account_detail').template_options
      end
        
      account_detail.merge!(
        rec_status: "T",
        seq_no: 1,
        acc_no: bank_account.account_number,
        idno: bank_account.id_number,
        initials: bank_account.initials,
        surname: bank_account.account_name,
        user_ref: user_ref
      )
      
      account_detail.merge!(branch_code: bank_account.branch_code) if external?
    end
  end
  
end

