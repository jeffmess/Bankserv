module Bankserv
  
  class Request < ActiveRecord::Base
    serialize :data
    
    self.inheritance_column = :_type_disabled
    
    scope :unprocessed, :where(:processed => false)
    
    def self.for_reference(reference)
      self.where(:user_ref => reference)
    end
    
    def self.process!
      self.unprocessed.each do |request|
        request.process!
      end
    end
    
    def process!
      
    end
  
  end
  
end