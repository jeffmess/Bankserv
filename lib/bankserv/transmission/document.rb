module Bankserv
  
  class Document < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    
    belongs_to :set
    has_many :sets
    serialize :error
        
    def mark_processed!
      self.update_attributes!(processed: true)
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
    
    def sets
      set.contained_sets
    end
    
    def records # unordered flat array records
      sets.map(&:records).flatten
    end
    
    def set_with_generation_number(generation_number)
      sets.select{|set| set.generation_number == generation_number}.first
    end
  
  end
  
end