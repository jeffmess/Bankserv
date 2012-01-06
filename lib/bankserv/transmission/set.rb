module Bankserv
  
  class Set < ActiveRecord::Base
    
    belongs_to :document
    has_many :records
    
    def rec_status # is it test/live data
      self.document && self.document.rec_status ? self.document.rec_status : "T"
    end
    
    def header
      records.select {|rec| rec.type == "header"}.first
    end
    
    def trailer
      records.select {|rec| rec.type == "trailer"}.first
    end
    
    def decorate_records
      klass = "Absa::H2h::Transmission::#{self.class.partial_class_name}".constantize
      
      records.each do |record|
        defaults = klass.record_type(record.type).template_options
        record.data = defaults.merge(record.data)
        record.data[:rec_status] = self.rec_status
      end
      
      self.records.each{|rec| rec.save!}
    end
    
    def self.partial_class_name
      self.name.split("::")[-1]
    end
    
    def number_of_records
      records.count
    end
    
    def to_hash
      {
        type: self.class.partial_class_name.underscore,
        data: records.collect{|rec| {type: rec.type, data: rec.data}}
      }
      
    end
    
  end
    
end