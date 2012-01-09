module Bankserv
  
  class Document < ActiveRecord::Base
    
    has_many :sets
    
    def self.has_work?
      defined_sets.any? {|set| set.has_work? }
    end
    
    def self.generate!(options = {})
      raise "Specify Live or Test env" unless options.has_key?(:mode)
      return unless self.has_work?
      
      document = Bankserv::Document.new(test: (options[:mode] == "T"))
      
      self.defined_sets.select(&:has_work?).each{|set| document.sets << set.generate}
      
      document.sets << Bankserv::Transmission::UserSet::Document.generate(options.merge(number_of_records: document.number_of_records + 2))
    
      document.save!
      document
    end
    
    def number_of_records
      sets.inject(0) {|res, e| res + e.number_of_records}
    end
    
    def self.defined_sets
      [
        Bankserv::Transmission::UserSet::AccountHolderVerification, 
        Bankserv::Transmission::UserSet::Debit
      ]
    end
    
    def rec_status
      (test == true) ? "T" : "L"
    end
    
    def to_hash
      document_set = sets.select{|set| set.is_a?(Bankserv::Transmission::UserSet::Document)}.first
      other_sets = sets.select{|set| not set.is_a?(Bankserv::Transmission::UserSet::Document)}
      
      {
        type: 'document',
        data: [
          {type: 'header', data: document_set.header.data},
          other_sets.collect{|set| set.to_hash},
          {type: 'trailer', data: document_set.trailer.data}
        ].flatten
      }
    end
  
  end
  
end