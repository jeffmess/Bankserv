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
    
    def self.user_code
      self.active.user_code
    end
    
    def self.department_code
      self.active.department_code
    end
  end
  
end