module Bankserv
  
  module Transmission
  module UserSet
  
    class Document < Set
    
      before_save :decorate_records
      after_save :set_header, :set_trailer
    
      def self.generate(options)
        puts "generating document set"
        puts options.inspect
        set = self.new
        set.build_header(options)
        set.build_trailer(number_of_records: options[:number_of_records])
        set
      end
    
      def build_header(options)
        self.records << Record.new(type: "header", data: {
          th_for_use_of_ld_user: options[:th_for_use_of_ld_user],
          th_client_code: options[:client_code],
          th_client_name: options[:client_name],
          th_transmission_no: options[:transmission_number]
        })
      end
    
      def build_trailer(options)
        self.records << Record.new(type: "trailer", data: {number_of_records: options[:number_of_records]})
      end
   
      private
    
      def set_header
        header.data[:th_date] = Date.today.strftime("%Y%m%d")
        header.data[:th_destination] = "0"
        header.save!
      end
    
      def set_trailer
        trailer.save!
      end
    
    end
  
  end
  end
  
end