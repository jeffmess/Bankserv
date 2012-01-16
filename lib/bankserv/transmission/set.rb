module Bankserv
  
  class Set < ActiveRecord::Base
    
    belongs_to :document
    has_many :records
    
    def build_header(options = {})
      self.records << Record.new(record_type: "header", data: options)
    end
  
    def build_trailer(options = {})
      self.records << Record.new(record_type: "trailer", data: options)
    end
    
    def rec_status # is it test/live data
      self.document && self.document.rec_status ? self.document.rec_status : "T"
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
          transactions.collect{|rec| {type: rec.record_type, data: rec.data}},
          trailer.to_hash
        ].flatten
      }
    end
    
    def process
      
    end
    
  end
    
end