module Bankserv
  
  class Record < ActiveRecord::Base
    self.inheritance_columns = :_type_disabled
    
    belongs_to :batch
  
  end
  
end