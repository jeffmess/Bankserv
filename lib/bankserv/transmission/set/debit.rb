module Bankserv
  module Transmission::UserSet
  
    class Debit < Eft
      
      before_save :decorate_records, :decorate_header, :decorate_trailer
      
      attr_accessor :type_of_service, :account_type_correct, :accepted_report
      
      def self.class_type
        Bankserv::Debit
      end
      
      def class_type
        Bankserv::Debit
      end
      
      def rec_id
        '001'
      end
      
      def standard_bankserv_record_identifier
        "50"
      end
      
      def standard_entry_class
        "44"
      end
            
      def contra_bankserv_record_identifier
        "52"
      end
      
      def total_debit_value
        standard_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def total_credit_value
        contra_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def no_debit_records
        self.records.where(record_type: "standard_record").count.to_s
      end
      
      def no_credit_records
        self.records.where(record_type: "contra_record").count.to_s
      end

    end
  end
end
