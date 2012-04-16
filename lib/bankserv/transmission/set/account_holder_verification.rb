module Bankserv
  module Transmission::UserSet
  
    class AccountHolderVerification < Set
    
      before_create :set_header, :set_trailer, :decorate_records
    
      def self.generate(options = {})
        [:internal, :external].collect do |type|
          ahvs = Bankserv::AccountHolderVerification.unprocessed.send(type)
          
          if options[:rec_status] == "L"
            ahvs.select!{|ahv| not ahv.request.test?}
          else
            ahvs.select!{|ahv| ahv.request.test?}            
          end
          
          if ahvs.count > 0
            set = self.new
            set.build_header
            ahvs.each{|ahv| set.build_transaction(ahv)}
            set.build_trailer
            set
          end
        end.compact
      end
    
      def self.has_work?
        Bankserv::AccountHolderVerification.unprocessed.select{|item| not item.request.test?}.any?
      end
      
      def self.has_test_work?
        Bankserv::AccountHolderVerification.unprocessed.select{|item| item.request.test?}.any?
      end
    
      def build_transaction(ahv)
        record_data = if ahv.external?
          Absa::H2h::Transmission::AccountHolderVerification.record_type('external_account_detail').template_options
        else
          Absa::H2h::Transmission::AccountHolderVerification.record_type('internal_account_detail').template_options
        end
        
        record_data.merge!(
          seq_no: (transactions.count + 1).to_s,
          account_number: ahv.bank_account.account_number,
          id_number: ahv.bank_account.id_number,
          initials: ahv.bank_account.initials,
          surname: ahv.bank_account.account_name,
          user_ref: ahv.internal_user_ref
        )
      
        record_data.merge!(branch_code: ahv.bank_account.branch_code) if ahv.external?
        
        record_type = ahv.internal? ? "internal_account_detail" : "external_account_detail"      
        records.build(record_type: record_type, data: record_data)
      end
    
      def account_number_total
        transactions.inject(0) {|res, e| res + e.data[:account_number].to_i}
      end
   
      private
      
      def bankserv_service
        self.class.bankserv_service
      end

      def self.bankserv_service
        Bankserv::AHVService.where(active: true).last
      end
    
      def set_header
        self.generation_number = bankserv_service.reserve_generation_number!.to_s
        header.data[:gen_no] = generation_number
        header.data[:dept_code] = bankserv_service.config[:department_code]
      end
    
      def set_trailer
        trailer.data[:no_det_recs] = transactions.count.to_s
        trailer.data[:acc_total] = account_number_total.to_s
      end
    
    end
  
  end
end