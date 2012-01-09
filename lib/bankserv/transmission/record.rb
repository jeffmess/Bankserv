module Bankserv
  
  class Record < ActiveRecord::Base
    belongs_to :set
    serialize :data
  end
  
end