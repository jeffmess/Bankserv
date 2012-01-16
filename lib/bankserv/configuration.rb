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
    
    def self.set_user_generation_number!(number)
      self.active.update_attributes!(user_generation_number: number)
    end
    
    def self.reserve_user_generation_number!
      reserved = self.user_generation_number
      self.set_user_generation_number!(reserved + 1)
      return reserved
    end
  end
  
end