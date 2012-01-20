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
      
      def debit_records
        contra_records
      end
      
      def credit_records
        standard_records
      end
          
    end
  end
end
