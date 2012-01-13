module Bankserv
  
  module Transmission
  module UserSet
  
    class AccountHolderVerificationOutput < Set
    
      before_save :decorate_records
    
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
        not Bankserv::AccountHolderVerification.unprocessed.empty?
      end
    
      def transactions
        records.select {|rec| !(["header", "trailer"].include? rec.record_type)  }
      end
    
      def build_header
        self.records << Record.new(record_type: "header", data: {})
      end
    
      def build_trailer
        self.records << Record.new(record_type: "trailer", data: {})
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
          user_ref: ahv.user_ref
        )
      
        record_data.merge!(branch_code: ahv.bank_account.branch_code) if ahv.external?
      
        self.records << Record.new(record_type: ahv.record_type, data: record_data)
      end
    
      def account_number_total
        transactions.inject(0) {|res, e| res + e.data[:account_number].to_i}
      end
   
      private
    
      def decorate_records   
        records.each do |record|
          defaults = Absa::H2h::Transmission::AccountHolderVerification.record_type(record.record_type).template_options
          record.data = defaults.merge(record.data)
          record.data[:rec_status] = self.rec_status
        end
      
        self.records.each{|rec| rec.save!}
      end
     
    end
   
  end 
  end
  
end