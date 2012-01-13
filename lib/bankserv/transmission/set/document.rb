module Bankserv
  module Transmission
    module UserSet
  
      class Document < Set
    
        before_save :decorate_records
    
        def self.generate(options)
          set = self.new
          set.build_header(options)
          set.build_trailer(number_of_records: options[:number_of_records])
          set
        end
    
        def build_header(options)
          self.records << Record.new(record_type: "header", data: {
            th_for_use_of_ld_user: options[:th_for_use_of_ld_user],
            th_client_code: options[:client_code] || Bankserv::Configuration.active.client_code,
            th_client_name: options[:client_name] || Bankserv::Configuration.active.client_name,
            th_transmission_no: options[:transmission_number],
            th_date: Date.today.strftime("%Y%m%d"),
            th_destination: "0"
          })
        end
    
        def build_trailer(options)
          self.records << Record.new(record_type: "trailer", data: {tt_no_of_recs: options[:number_of_records].to_s})
        end
    
      end
  
    end
  end
end