module Bankserv
  module Transmission
    module UserSet
  
      class Document < Set
    
        before_save :decorate_records
    
        def self.generate(options)
          set = self.new
          set.build_header(options)
          set.build_trailer(no_of_recs: options[:no_of_recs])
          set
        end
    
        def build_header(options = {})
          defaults = {
            client_code: Bankserv::Configuration.active.client_code,
            client_name: Bankserv::Configuration.active.client_name,
            date: Date.today.strftime("%Y%m%d"),
            destination: "0"
          }
          
          self.records << Record.new(record_type: "header", data: defaults.merge(options))
        end
    
        def build_trailer(options = {})
          options[:no_of_recs] = options[:no_of_recs].to_s
          self.records << Record.new(record_type: "trailer", data: options)
        end
        
        def update_number_of_records! # refactor
          count = 0
          
          array = [self]
          
          while array.length > 0
            set = array.shift
            count += set.number_of_records
            array << set.sets
            array.flatten!
          end
          
          self.trailer.data.merge!(no_of_recs: count.to_s)
          self.save!
        end
    
      end
  
    end
  end
end