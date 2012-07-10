module Bankserv
  
  class Record < ActiveRecord::Base
    belongs_to :set
    belongs_to :sourceable, polymorphic: true
    serialize :data
    serialize :error
    
    def to_hash
      {type: record_type, data: data}
    end

  end
  
end