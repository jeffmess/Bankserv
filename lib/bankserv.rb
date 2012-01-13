require "active_record"
require "core_extensions"
require "bankserv/version"

module Bankserv
    
  def self.table_name_prefix
    'bankserv_'
  end
  
end

require "bankserv/configuration"
require "bankserv/eft"
require "bankserv/request"
require "bankserv/bank_account"
require "bankserv/account_holder_verification"
require "bankserv/debit"
require "bankserv/credit"

require 'bankserv/transmission/document'
require 'bankserv/transmission/set'
require 'bankserv/transmission/record'

require 'bankserv/transmission/set/document'
require 'bankserv/transmission/set/account_holder_verification'
require 'bankserv/transmission/set/account_holder_verification_output'
require 'bankserv/transmission/set/debit'