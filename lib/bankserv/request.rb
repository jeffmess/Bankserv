module Bankserv
  
  class Request < ActiveRecord::Base
    serialize :data
    
    self.inheritance_column = :_type_disabled
    
    after_create :delegate!
    
    def self.process!
      self.where(:processed => false).each{|request| request.process!}
    end
    
    def delegate!
      case type
      when 'ahv'
        AccountHolderVerification.build! data
      end
    end
  
  end
  
end