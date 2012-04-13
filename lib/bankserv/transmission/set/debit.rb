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
      
      def debit_records
        standard_records
      end
      
      def credit_records
        contra_records
      end
      
      def bankserv_service
        Bankserv::Service.where(active: true, type: 'debit').last
      end
      
      def self.bankserv_service
        Bankserv::Service.where(active: true, type: 'debit').last
      end

    end
  end
end
