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
      
      def bankserv_service
        Bankserv::Transmission::UserSet::Credit.bankserv_service
      end

      def self.bankserv_service
        Bankserv::CreditService.where(active: true).last
      end

      def self.generate(options = {})
        efts = self.unprocessed_efts(options[:rec_status])
        
        if efts.count > 0
          sets = efts.group_by(&:batch_id).map do |batch_id, efts|
            set = self.new
            set.type_of_service = efts.first.request.data[:type_of_service]
            set.accepted_report = efts.first.request.data[:accepted_report] || "Y"
            set.account_type_correct = efts.first.request.data[:account_type_correct] || "Y"
            set.build_header
            set.build_batches(efts)
            set.build_trailer
            set
          end
        end
      end

      def build_batches(efts)
        efts.select(&:standard?).each{|t| build_standard t}
        efts.select(&:contra?).each{|t| build_contra t}
      end
    end
  end
end
