module Bankserv
  module Transmission
  module UserSet
  
    class Debit < Set
    
      def self.generate
        set = self.new
      
        Bankserv::Debit.unprocessed.group_by(&:set_id).each do |set_id, debit_order|
        
        end
      end
    
      def self.has_work?
        Bankserv::Debit.has_work?
      end
    
    end

  end
  end  
end