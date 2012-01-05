module Bankserv
  
  class Batch < ActiveRecord::Base
    
    belongs_to :document
    has_many :records
    
  end
    
end