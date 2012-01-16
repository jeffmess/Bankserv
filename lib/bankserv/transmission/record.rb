module Bankserv
  
  class Record < ActiveRecord::Base
    belongs_to :set
    serialize :data
    
    def to_hash
      {type: record_type, data: data}
    end
  end
  
end