module Bankserv
  module Transmission::UserSet
  
    class Credit < Eft
      
      before_save :decorate_records, :decorate_header, :decorate_trailer
      
      attr_accessor :type_of_service, :accepted_report, :account_type_correct
      
      def self.class_type
        Bankserv::Credit
      end
      
      def class_type
        Bankserv::Credit
      end
      
      def rec_id
        '020'
      end
      
      def standard_bankserv_record_identifier
        "10"
      end
      
      def standard_entry_class
        "88"
      end
      
      def contra_bankserv_record_identifier
        "12"
      end
      
      def total_credit_value
        standard_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def total_debit_value
        contra_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def no_debit_records
        self.records.where(record_type: "contra_record").count.to_s
      end
      
      def no_credit_records
        self.records.where(record_type: "standard_record").count.to_s
      end
      
    end
  end
end
