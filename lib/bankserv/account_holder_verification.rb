module Bankserv
  
  class AccountHolderVerification < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    serialize :response
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    scope :unprocessed, where(status: "new")
    scope :internal, where(internal: true)
    scope :external, where(internal: false)
    
    after_create :generate_internal_user_ref
    
    def generate_internal_user_ref
      self.internal_user_ref = Bankserv::AccountHolderVerification.generate_reference_number(self)
      save!
    end
    
    def self.generate_reference_number(ahv)
      "AHV#{ahv.id}"
    end
    
    def self.service
      Bankserv::AHVService.where(active: true).last
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.for_internal_reference(reference)
      self.where(:internal_user_ref => reference)
    end
    
    def self.build!(options)
      bank_account = BankAccount.new(options.delete(:bank_account))
      is_internal = bank_account.branch_code == self.service.config[:internal_branch_code]
      ahv = new(options)
      ahv.bank_account = bank_account
      ahv.internal = is_internal
      ahv.save!
    end
    
    def internal?
      internal == true
    end
    
    def external?
      !internal?
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
    
    def process_response(data)
      file_name = "#{Bankserv::CONFIG_DIR}/ahv.yml"
      return_code_mapping = YAML.load(File.open(file_name))['return_codes']
      
      hash = {
        account_number: return_code_mapping[data[:return_code_1]].to_sym,
        id_number: return_code_mapping[data[:return_code_2]].to_sym,
        initials: return_code_mapping[data[:return_code_3]].to_sym,
        surname: return_code_mapping[data[:return_code_4]].to_sym
      }
      
      self.response = hash
      self.status = "completed"
      self.save!
    end
    
  end
  
end

