module Bankserv
  module Eft
    # This module is tightly coupled to the Debit and Credit class.
    # Any change here will ripple down...
    attr_accessor :request_id
    
    def request(options)
      Request.create!(options)
    end
    
    def test_request(options)
      Request.create!(options.merge(test: true))
    end
    
    def build!(options)
      @request_id = options[:bankserv_request_id]
      
      options[:batches].each do |batch|
        build_batch! batch
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
      options = options.filter_attributes(self).merge(bank_account: BankAccount.new(ba_options), record_type: "contra", batch_id: batch_id, bankserv_request_id: @request_id)
      
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
      options = options.filter_attributes(self).merge(bank_account: BankAccount.new(ba_options), record_type: "standard", batch_id: batch_id, bankserv_request_id: @request_id)
      
      create!(options)
    end
    
    def next_batch_id
      maximum('batch_id').nil? ? 1 : maximum('batch_id') + 1
    end
    
    def has_work?
      unprocessed.select{|item| not item.request.test?}.any?
    end
    
    def has_test_work?
      unprocessed.select{|item| item.request.test?}.any?
    end
    
    def self.for_reference(reference)
      Debit.for_reference(reference) + Credit.for_reference(reference)
    end
    
    def self.for_internal_reference(reference)
      Debit.for_internal_reference(reference) + Credit.for_internal_reference(reference)
    end
    
  end
end