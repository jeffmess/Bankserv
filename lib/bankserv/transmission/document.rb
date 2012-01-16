module Bankserv
  
  class Document < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    
    has_many :sets
    
    def self.has_work?
      defined_input_sets.any? {|set| set.has_work? }
    end
    
    def self.generate!(options = {})
      raise "Specify Live or Test env" unless options.has_key?(:mode)
      return unless self.has_work?
      
      document = Bankserv::Document.new(test: (options[:mode] == "T"), type: 'input')
      
      self.defined_input_sets.select(&:has_work?).each{|set| document.sets << set.generate}
      
      document.sets << Bankserv::Transmission::UserSet::Document.generate(options.merge(no_of_recs: document.number_of_records + 2))
    
      document.save!
      document
    end
    
    def number_of_records
      sets.inject(0) {|res, e| res + e.number_of_records}
    end
    
    def self.defined_input_sets
      [
        Bankserv::Transmission::UserSet::AccountHolderVerification, 
        Bankserv::Transmission::UserSet::Debit
      ]
    end
    
    def rec_status
      (test == true) ? "T" : "L"
    end
    
    def to_hash
      document_sets, other_sets = sets.partition{|set| set.is_a?(Bankserv::Transmission::UserSet::Document)}
      
      {
        type: 'document',
        data: [
          document_sets.first.header.to_hash,
          other_sets.collect{|set| set.to_hash},
          document_sets.first.trailer.to_hash
        ].flatten
      }
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
      
      header_options = options[:data].select{|h| h[:type] == 'header'}.first
      trailer_options = options[:data].select{|h| h[:type] == 'trailer'}.first
      set_options = options[:data].select{|h| not ['header','trailer'].include?(h[:type])}
      
      document = Bankserv::Document.new(type: 'output')
      document_set = Bankserv::Transmission::UserSet::Document.new
      document_set.build_header header_options[:data]
      document_set.build_trailer trailer_options[:data]
      document.sets << document_set
      
      set_options.each do |set_option|
        klass = "Bankserv::Transmission::UserSet::#{set_option[:type].camelize}".constantize
        set = klass.new
        set_option[:data].each{|h| set.records << Record.new(record_type: h[:type], data: h[:data], reference: h[:data][:user_ref])}
        document.sets << set
      end
      
      document.save!
      document
    end
    
    def self.process_output_document(document)
      raise "Expected output document" unless document.output?
      
      document.sets.each do |set|
        set.process
      end
    end
  
  end
  
end