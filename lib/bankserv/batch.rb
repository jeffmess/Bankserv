module Bankserv
  
  class Batch < ActiveRecord::Base
    
    belongs_to :document
    has_many :records
    
    def rec_status # is it test/live data
      self.document && self.document.rec_status ? self.document.rec_status : "T"
    end
    
  end
    
end