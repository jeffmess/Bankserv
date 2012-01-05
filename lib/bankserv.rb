require "active_record"
require "bankserv/version"

module Bankserv
    
  def self.table_name_prefix
    'bankserv_'
  end
  
end

require "bankserv/eft"
require "bankserv/request"
require "bankserv/bank_account"
require "bankserv/account_holder_verification"
require "bankserv/debit"
require "bankserv/credit"
require 'bankserv/document'
require 'bankserv/batch'
require 'bankserv/record'

require 'bankserv/batch/account_holder_verification_batch'