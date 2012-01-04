require "active_record"
require "bankserv/version"
require "bankserv/request"
require "bankserv/account_holder_verification"

module Bankserv
  
#  class ActiveRecord::Base
    
    def self.table_name_prefix
      'bankserv_'
    end
  
    # def self.set_inheritance_column
    #   'giraffe'
    # end
  
#  end
  
end
