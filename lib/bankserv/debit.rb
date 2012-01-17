module Bankserv
  
  class Debit < ActiveRecord::Base
    extend Eft
    
    scope :unprocessed, where(processed: false)
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    belongs_to :request, :foreign_key => 'bankserv_request_id'
    
    after_create :generate_internal_user_ref
    
    def generate_internal_user_ref
      self.internal_user_ref = "DEBIT#{id}"
      save!  
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
        Debit.where(record_type: "contra", batch_id: self.batch_id, processed: false).first.bank_account
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
      # file_name = "#{Bankserv::CONFIG_DIR}/ahv.yml"
      #       return_code_mapping = YAML.load(File.open(file_name))['return_codes']
      #       
      #       hash = {
      #         account_number: return_code_mapping[data[:return_code_1]].to_sym,
      #         id_number: return_code_mapping[data[:return_code_2]].to_sym,
      #         initials: return_code_mapping[data[:return_code_3]].to_sym,
      #         surname: return_code_mapping[data[:return_code_4]].to_sym
      #       }
      #       
      #       self.response = hash
      self.status = "completed"
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
  end
  
end
