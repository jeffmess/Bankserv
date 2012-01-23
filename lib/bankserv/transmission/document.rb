module Bankserv
  
  class Document < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    
    belongs_to :set
    
    def self.has_work?
      defined_input_sets.any? {|set| set.has_work? }
    end
    
    def self.generate!(options = {})
      raise "Specify Live or Test env" unless options.has_key?(:mode)
      return unless self.has_work?
      
      options[:transmission_no] ||= Bankserv::Configuration.reserve_transmission_number!
      
      mode = options.delete(:mode)
      
      document = Bankserv::Document.new(test: (mode == "T"), type: 'input', transmission_number: options[:transmission_no])
      document.set = Bankserv::Transmission::UserSet::Document.generate(options)
      document.set.document = document # whaaaaaa?
      
      self.defined_input_sets.select(&:has_work?).each do |set| 
        document.set.sets << set.generate
        document.set.sets[-1].set = document.set # whaaaaaa?
      end
      
      document.save!
      document
    end
        
    def self.defined_input_sets
      [
        Bankserv::Transmission::UserSet::AccountHolderVerification, 
        Bankserv::Transmission::UserSet::Debit,
        Bankserv::Transmission::UserSet::Credit
      ]
    end
    
    def rec_status
      (test == true) ? "T" : "L"
    end
    
    def to_hash
      set.to_hash
    end
    
    def input?
      type == 'input'
    end
    
    def output?
      type == 'output'
    end
    
    def reply?
      type == 'reply'
    end
    
    def self.store_output_document(string)
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'output')
      
      raise "WTH" unless options[:type] == "document"
      
      document = Bankserv::Document.new(type: 'output')
      document.set = Bankserv::Set.from_hash(options)
      document.set.document = document # whaaaaaa?
      document.save!
      document
    end
    
    def self.store_input_document(string)
      options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
      
      raise "WTH" unless options[:type] == "document"
      
      document = Bankserv::Document.new(type: 'input', transmission_number: options[:data][0][:data][:transmission_no])
      document.set = Bankserv::Set.from_hash(options)
      document.set.document = document # whaaaaaa?
      document.save!
      document      
    end
    
    def self.process_output_document(document)
      raise "Expected output document" unless document.output?
      raise "Document already processed" if document.processed?
      
      document.set.process
      document.processed = true
      document.save
    end
  
  end
  
end