module Bankserv
  
  module Transmission
  module UserSet
  
    class Document < Set
    
      before_save :decorate_records
      after_save :set_header, :set_trailer
    
      def self.generate(options)
        set = self.new
        set.build_header
        set.build_trailer(number_of_records: options[:number_of_records])
        set
      end
    
      def build_header
        self.records << Record.new(type: "header", data: {})
      end
    
      def build_trailer(options)
        self.records << Record.new(type: "trailer", data: {number_of_records: options[:number_of_records]})
      end
   
      private
    
      def set_header
        header.save!
      end
    
      def set_trailer
        trailer.save!
      end
    
    end
  
  end
  end
  
end