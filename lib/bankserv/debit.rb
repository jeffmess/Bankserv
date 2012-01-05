module Bankserv
  
  class Debit < ActiveRecord::Base

    self.inheritance_column = :_type_disabled
    
    belongs_to :bank_account, :foreign_key => 'bankserv_bank_account_id'
    
    def self.request(options)
      Request.create!(options)
    end
    
    def self.build!(options)
      contra_record = self.build_contra!(options[:credit])
      self.build_standard!(contra_record, options[:debit])
    end
    
    def self.build_contra!(options)
      ba_options = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)
      
      self.create!(bank_account: BankAccount.new(ba_options), user_ref: options[:user_ref], type: "contra")
    end
    
    def self.build_standard!(contra_record, options)
      if options.is_a? Array
        options.each do |debit|
          self.create_standard!(contra_record.id, debit)
        end
      else
        self.create_standard!(contra_record.id, options)
      end
    end
    
    def self.create_standard!(set_id, options)
      ba = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)

      self.create!(bank_account: BankAccount.new(ba), amount: options[:amount], action_date: options[:action_date], set_id: set_id, user_ref: options[:user_ref])
    end
  
  end
  
end
