module Bankserv
  
  class Configuration < ActiveRecord::Base
    
    def self.active
      self.where(active: true).last
    end
    
    def self.client_code
      self.active.client_code
    end
    
    def self.client_name
      self.active.client_name
    end
    
    def self.client_abbreviated_name
      self.active.client_abbreviated_name
    end
    
    def self.user_code
      self.active.user_code
    end
    
    def self.department_code
      self.active.department_code
    end
    
    def self.user_generation_number
      self.active.user_generation_number
    end
    
    def self.internal_branch_code
      self.active.internal_branch_code
    end
    
    def self.transmission_number
      self.active.transmission_number
    end
    
    def self.set_transmission_number!(number)
      self.active.update_attributes!(transmission_number: number)
    end
    
    def self.reserve_transmission_number!
      reserved = self.transmission_number
      self.set_transmission_number!(reserved + 1)
      reserved
    end
    
    def self.set_user_generation_number!(number)
      self.active.update_attributes!(user_generation_number: number)
    end
    
    def self.reserve_user_generation_number!
      reserved = self.user_generation_number
      self.set_user_generation_number!(reserved + 1)
      reserved
    end
    
    def self.live_env?
      self.active.live_env
    end
    
    def self.eft_sequence_number
      sequence_number = self.active.eft_sequence_number || 1
      sequence_number = 1 unless self.active.eft_sequence_number_updated_at.to_date == Date.today
      sequence_number
    end
    
    def self.set_eft_sequence_number!(number)
      self.active.update_attributes!(eft_sequence_number: number, eft_sequence_number_updated_at: Time.now)
    end
    
    def self.reserve_eft_sequence_number!(reserved = nil)
      reserved ||= self.eft_sequence_number
      self.set_eft_sequence_number!(reserved.to_i + 1)
      reserved
    end
  
  end
  
end