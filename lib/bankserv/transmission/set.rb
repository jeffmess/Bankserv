module Bankserv
  
  class Set < ActiveRecord::Base
    belongs_to :set
    has_many :sets
    
    has_one :document
    has_many :records
    
    def build_header(options = {})
      self.records << Record.new(record_type: "header", data: options)
    end
  
    def build_trailer(options = {})
      self.records << Record.new(record_type: "trailer", data: options)
    end
    
    def parent
      set
    end
    
    def rec_status # is it test/live data
      return parent.rec_status if parent
      return document.rec_status if document
      "T"
    end
    
    def header
      records.select {|rec| rec.record_type == "header"}.first
    end
    
    def trailer
      records.select {|rec| rec.record_type == "trailer"}.first
    end
    
    def transactions
      records.select {|rec| !(["header", "trailer"].include? rec.record_type)  }
    end
    
    def decorate_records
      klass = "Absa::H2h::Transmission::#{self.class.partial_class_name}".constantize
      
      records.each do |record|
        defaults = klass.record_type(record.record_type).template_options
        record.data = defaults.merge(record.data)
        record.data[:rec_status] = self.rec_status
      end
      
      self.records.each{|rec| rec.save!}
    end
    
    def self.partial_class_name
      self.name.split("::")[-1]
    end
    
    def number_of_records
      records.size
    end
    
    def to_hash
      {
        type: self.class.partial_class_name.underscore,
        data: [
          header.to_hash,
          transactions.collect{|rec| rec.to_hash},
          sets.collect{|s| s.to_hash},
          trailer.to_hash
        ].flatten
      }
    end
    
    def process
      sets.each{|s| s.process}
    end
    
    def self.from_hash(options)
      header_options = options[:data].select{|h| h[:type] == 'header'}.first
      trailer_options = options[:data].select{|h| h[:type] == 'trailer'}.first
      transaction_options = options[:data].select{|h| not ['header','trailer'].include?(h[:type])}
      
      klass = "Bankserv::Transmission::UserSet::#{options[:type].camelize}".constantize
      set = klass.new
      set.build_header header_options[:data]
      
      transaction_options.each do |option|
        if option[:data].is_a? Array
          set.sets << self.from_hash(option)
        else
          set.records << Record.new(record_type: option[:type], data: option[:data], reference: option[:data][:user_ref])
        end
      end
      
      set.build_trailer trailer_options[:data]
      set
    end
    
  end
    
end