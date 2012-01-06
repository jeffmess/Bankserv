module Bankserv
  
  class Document < ActiveRecord::Base
    
    has_many :sets
    
    def self.has_work?
      sets.any? {|set| set.has_work? }
    end
    
    def self.create_documents!
      return unless self.has_work?
      
      document = Bankserv::Document.new
      
      self.sets.select(&:has_work?).each do |set|
        puts set.name
        document.sets << set.create_sets
      end
      
      document.build_set
      puts document.sets.inspect
      document.save!
      document
    end
    
    def build_set # represents the document itself (its header and trailer records)
      self.sets << Bankserv::Transmission::UserSet::Document.generate(number_of_records: number_of_records + 2)
    end
    
    def number_of_records
      sets.inject(0) {|res, e| res + e.number_of_records}
    end
    
    def self.sets
      [
        Bankserv::Transmission::UserSet::AccountHolderVerification, 
        Bankserv::Transmission::UserSet::Debit
      ]
    end
    
    def rec_status
      "T"
    end
    
    def to_hash
      document_set = sets.select{|set| set.is_a?(Bankserv::Transmission::UserSet::Document)}.first
      other_sets = sets.select{|set| not set.is_a?(Bankserv::Transmission::UserSet::Document)}
      
      puts document_set.inspect
      puts other_sets.inspect
      
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