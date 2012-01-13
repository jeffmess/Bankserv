module Bankserv
  
  class AccountHolderVerification < ActiveRecord::Base
    
    self.inheritance_column = :_type_disabled
    serialize :response
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    scope :unprocessed, where(status: "new")
    scope :internal, where(internal: true)
    scope :external, where(internal: false)
  
    def self.request(options)
      Request.create!(options)
    end
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.build!(options)
      bank_account = BankAccount.new options[:bank_account].filter_attributes(BankAccount)
      is_internal = bank_account.branch_code == Bankserv::Configuration.internal_branch_code
      options = options.filter_attributes(self).merge(bank_account: bank_account, internal: is_internal)
      
      create!(options)
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

