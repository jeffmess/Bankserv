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
      ba_options = options.filter_attributes(BankAccount)
      options = options.filter_attributes(self).merge(bank_account: BankAccount.new(ba_options), record_type: "contra", batch_id: batch_id)
      
      create!(options)
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
      ba_options = options.filter_attributes(BankAccount)
      options = options.filter_attributes(self).merge(bank_account: BankAccount.new(ba_options), record_type: "standard", batch_id: batch_id)
      
      create!(options)
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