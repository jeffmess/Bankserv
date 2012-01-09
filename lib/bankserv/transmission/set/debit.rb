module Bankserv
  module Transmission::UserSet
  
    class Debit < Set
    
      def self.generate
        set = self.new
      
        Bankserv::Debit.unprocessed.group_by(&:set_id).each do |set_id, debit_order|
        
        end
      end
    
      def self.has_work?
        Bankserv::Debit.has_work?
      end
      
      def self.create_sets  
        if Bankserv::Debit.unprocessed.count > 0
          set = self.new
          set.build_header
          Bankserv::Debit.unprocessed.each{|debit| set.build_transaction(debit)}
          # set.build_trailer
          set
        end
      end
      
      def build_header
        self.records << Record.new(type: "header", data: {})
      end
      
      def user_sequence_number
        transactions.count < 2 ? 1 : transactions.count + 1
      end
      
      def transactions
        records.select {|rec| !(["header", "trailer"].include? rec.record_type)  }
      end
      
      def build_transaction(debit)
        if debit.standard?
          record_data = Absa::H2h::Transmission::Eft.record_type('standard_record').template_options
        else
          record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options
        end
        
        record_data.merge!(
          rec_id: "001",
          bankserv_record_identifier: 50,
          user_branch: "RC",
          user_nominated_account: "RC Franchise acc",
          user_code: "RC UC",
          user_sequence_number: user_sequence_number,
          homing_branch: debit.bank_account.branch_code,
          homing_account_number: debit.bank_account.account_number,
          type_of_account: debit.bank_account.account_type,
          amount: debit.amount,
          action_date: debit.action_date,
          entry_class: 41,
          tax_code: 0,
          user_ref: debit.user_ref,
          homing_account_name: debit.bank_account.account_name,
          non_standard_homing_account_number: '',
          homing_institution: 21
        )
        
        self.records << Record.new(type: debit.record_type + "_record", data: record_data)
      end
    end
  end
end

