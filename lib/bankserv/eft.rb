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
      set_id = next_set_id
      if self.partial_class_name == "Debit"
        build_standard!(set_id, options[:debit])
        build_contra!(set_id, options[:credit])
      else
        build_standard!(set_id, options[:credit])
        build_contra!(set_id, options[:debit])
      end
    end
    
    def partial_class_name
      self.name.split("::")[-1]
    end
    
    def build_contra!(set_id, options)
      ba_options = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)
      
      create!(bank_account: BankAccount.new(ba_options), user_ref: options[:user_ref], amount: options[:amount], set_id: set_id, action_date: options[:action_date], record_type: "contra")
    end
    
    def build_standard!(set_id, options)
      if options.is_a? Array
        options.each do |debit|
          create_standard!(set_id, debit)
        end
      else
        create_standard!(set_id, options)
      end
    end
    
    def create_standard!(set_id, options)
      ba = BankAccount.extract_hash(options)
      options = options.except(:branch_code, :account_number, :account_type, :intials, :account_name, :id_number, :initials)

      create!(bank_account: BankAccount.new(ba), amount: options[:amount], action_date: options[:action_date], set_id: set_id, user_ref: options[:user_ref], record_type: "standard")
    end
    
    def next_set_id
      maximum('set_id').nil? ? 1 : maximum('set_id') + 1
    end
    
    def has_work?
      return true unless unprocessed.empty?
      false
    end
  end
end