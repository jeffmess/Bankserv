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
    
        def build_header(options)
          self.records << Record.new(record_type: "header", data: {
            th_for_use_of_ld_user: options[:th_for_use_of_ld_user],
            client_code: options[:client_code] || Bankserv::Configuration.active.client_code,
            client_name: options[:client_name] || Bankserv::Configuration.active.client_name,
            transmission_no: options[:transmission_no],
            date: options[:date] || Date.today.strftime("%Y%m%d"),
            destination: options[:destination] || "0"
          })
        end
    
        def build_trailer(options)
          self.records << Record.new(record_type: "trailer", data: {no_of_recs: options[:no_of_recs].to_s})
        end
    
      end
  
    end
  end
end