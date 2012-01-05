require "active_record"
require "bankserv/version"

module Bankserv
    
  def self.table_name_prefix
    'bankserv_'
  end
  
end

require "bankserv/request"
require "bankserv/bank_account"
require "bankserv/account_holder_verification"
