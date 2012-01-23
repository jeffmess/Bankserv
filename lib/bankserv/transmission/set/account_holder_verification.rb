module Bankserv
  module Transmission::UserSet
  
    class AccountHolderVerification < Set
    
      before_save :set_trailer, :decorate_records
      after_save :set_header
    
      def self.generate
        [:internal, :external].collect do |type|
          if Bankserv::AccountHolderVerification.unprocessed.send(type).count > 0
            set = self.new
            set.build_header
            Bankserv::AccountHolderVerification.unprocessed.send(type).each{|ahv| set.build_transaction(ahv)}
            set.build_trailer
            set
          end
        end.compact
      end
    
      def self.has_work?
        Bankserv::AccountHolderVerification.unprocessed.any?
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
        self.records << Record.new(record_type: record_type, data: record_data)
      end
    
      def account_number_total
        transactions.inject(0) {|res, e| res + e.data[:account_number].to_i}
      end
   
      private
    
      def set_header
        self.generation_number = Bankserv::Configuration.reserve_user_generation_number!.to_s
        header.data[:gen_no] = generation_number
        header.data[:dept_code] = Bankserv::Configuration.department_code
        header.save!
      end
    
      def set_trailer
        trailer.data[:no_det_recs] = self.transactions.count.to_s
        trailer.data[:acc_total] = self.account_number_total.to_s
        trailer.save!
      end
    
    end
  
  end
end