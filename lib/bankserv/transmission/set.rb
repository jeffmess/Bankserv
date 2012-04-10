module Bankserv
  
  class Set < ActiveRecord::Base
    belongs_to :set
    belongs_to :document
    has_many :sets
    
    has_many :records
    
    def build_header(options = {})
      records.build(record_type: "header", data: options)
    end
  
    def build_trailer(options = {})
      records.build(record_type: "trailer", data: options)
    end
    
    def parent
      set
    end
    
    def rec_status # is it test/live data
      return document.rec_status if document
      return parent.rec_status if parent
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
      klass = "Absa::H2h::Transmission::#{set_type.camelize}".constantize
      
      records.each do |record|
        defaults = klass.record_type(record.record_type).template_options
        record.data = defaults.merge(record.data)
        record.data[:rec_status] ||= rec_status
      end
      
      self.records.each{|rec| rec.save!} # TODO: does this cause records to save before set?
    end
    
    def self.partial_class_name
      self.name.split("::")[-1]
    end
    
    def number_of_records
      records.size + sets.inject(0) { |sum, set| sum + set.number_of_records }
    end
    
    def set_type
      self.class.partial_class_name.underscore
    end
    
    def to_hash
      data = []
      data << header.to_hash if header
      data << transactions.collect{|rec| rec.to_hash}
      data << sets.collect{|s| s.to_hash}
      data << trailer.to_hash if trailer
      data.flatten!
      
      {
        type: set_type,
        data: data
      }
    end
    
    def process
      sets.each{|s| s.process}
    end
    
    def self.from_hash(options)
      header_options = options[:data].select{|h| h[:type] == 'header'}.first
      trailer_options = options[:data].select{|h| h[:type] == 'trailer'}.first
      transaction_options = options[:data].select{|h| not ['header','trailer'].include?(h[:type])}

      klass_name = "Bankserv::Transmission::UserSet::#{options[:type].camelize}"
      
      if klass_name == "Bankserv::Transmission::UserSet::Eft"
        # hack for debit/credit eft
        klass_name = "Bankserv::Transmission::UserSet::Debit" if header_options[:data][:rec_id] == "001"
        klass_name = "Bankserv::Transmission::UserSet::Credit" if header_options[:data][:rec_id] == "020"  
      end
      
      set = klass_name.constantize.new
      set.build_header(header_options[:data]) if header_options
      
      transaction_options.each do |option|
        if option[:data].is_a? Array
          set.sets << self.from_hash(option)
        else
          set.records << Record.new(record_type: option[:type], data: option[:data], reference: option[:data][:user_ref])
        end
      end
      
      set.build_trailer(trailer_options[:data]) if trailer_options
      set
    end
    
    def contained_sets
      ([self] + sets.map(&:contained_sets)).flatten
    end
    
    def record_with_sequence_number(sequence_number)
      transactions.select{|rec| rec.data[:user_sequence_number] == sequence_number}.first
    end
    
    def base_set
      return parent.base_set if parent
      self
    end
    
    def get_document
      base_set.document
    end
    
  end
    
end