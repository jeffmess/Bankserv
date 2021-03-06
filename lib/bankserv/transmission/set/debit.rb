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
        Bankserv::Transmission::UserSet::Debit.bankserv_service
        #Bankserv::Service.where(active: true, type: 'debit').last
      end

      def self.bankserv_service
        Bankserv::DebitService.where(active: true).last
        #Bankserv::Service.where(active: true, type: 'debit').last
      end

      def build_batches(efts)
        build_header

        efts.group_by(&:batch_id).each do |batch_id, eft|
          eft.select(&:standard?).each{|t| build_standard t}
          eft.select(&:contra?).each{|t| build_contra t}
        end

        build_trailer
      end

    end
  end
end
