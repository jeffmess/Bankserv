module Bankserv
  module Eft
    # This module is tightly coupled to the Debit and Credit class.
    # Any change here will ripple down...
    
    def request(options)
      Request.create!(options)
    end
    
    def build!(options)
      if options.is_a? Array
        options.each do |batch|
          build_batch! batch
        end
      else
        build_batch! options
      end
    end
    
    def build_batch!(options)
      batch_id = next_batch_id
      if self.partial_class_name == "Debit"
        build_standard!(batch_id, options[:debit])
        build_contra!(batch_id, options[:credit])
      else
        build_standard!(batch_id, options[:credit])
        build_contra!(batch_id, options[:debit])
      end
    end
    
    def partial_class_name
      self.name.split("::")[-1]
    end
    
    def build_contra!(batch_id, options)
      ba_options = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)
      
      create!(bank_account: BankAccount.new(ba_options), user_ref: options[:user_ref], amount: options[:amount], batch_id: batch_id, action_date: options[:action_date], record_type: "contra")
    end
    
    def build_standard!(batch_id, options)
      if options.is_a? Array
        options.each do |debit|
          create_standard!(batch_id, debit)
        end
      else
        create_standard!(batch_id, options)
      end
    end
    
    def create_standard!(batch_id, options)
      ba = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)

      create!(bank_account: BankAccount.new(ba), amount: options[:amount], action_date: options[:action_date], batch_id: batch_id, user_ref: options[:user_ref], record_type: "standard")
    end
    
    def next_batch_id
      maximum('batch_id').nil? ? 1 : maximum('batch_id') + 1
    end
    
    def has_work?
      return true unless unprocessed.empty?
      false
    end
  end
end