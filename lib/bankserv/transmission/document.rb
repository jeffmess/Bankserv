module Bankserv
  
  class Document < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    
    belongs_to :set
    serialize :error
    
    #before_save :set_transmission_number
    
    def set_transmission_number
      puts self.transmission_number.inspect
      if set && set.header && set.header.data && set.header.data[:transmission_no]
        #self.transmission_number = set.header.data[:transmission_no]
       # puts self.inspect
      end
    end
    
    def self.has_work?
      defined_input_sets.any? {|set| set.has_work? }
    end
    
    def self.has_test_work?
      defined_input_sets.any? {|set| set.has_test_work? }
    end
    
    def self.fetch_next_transmission_number
      if Bankserv::Configuration.live_env?
        Bankserv::Document.where(type: 'input', reply_status: 'ACCEPTED', transmission_status: "L").maximum(:transmission_number)
      else
        Bankserv::Document.where(type: 'input', reply_status: 'ACCEPTED', transmission_status: "T").maximum(:transmission_number)
      end
    end
    
    def self.generate_test!(options = {})
      return unless self.has_test_work?
      self.build!(options.merge(rec_status: "T"))
    end
    
    def self.generate!(options = {})
      return unless self.has_work?
      self.build!(options.merge(rec_status: "L"))
    end
    
    def self.build!(options = {}) # move to private      
      options[:transmission_no] ||= self.fetch_next_transmission_number
      
      transmission_status = Bankserv::Configuration.live_env? ? "L" : "T"
      
      document = Bankserv::Document.new(transmission_status: transmission_status, rec_status: options[:rec_status], type: 'input', transmission_number: options[:transmission_no])
      document.set = Bankserv::Transmission::UserSet::Document.generate(options.merge(rec_status: document.rec_status))
      document.set.document = document # whaaaaaa?
      
      sets_with_work = if document.rec_status == "L"
        self.defined_input_sets.select(&:has_work?)
      else
        self.defined_input_sets.select(&:has_test_work?)
      end
      
      sets_with_work.each do |set| 
        document.set.sets << set.generate(rec_status: document.rec_status)
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
      
      document = Bankserv::Document.new(type: 'input', transmission_number: options[:data][0][:data][:transmission_no], transmission_status: options[:data][0][:data][:rec_status])
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