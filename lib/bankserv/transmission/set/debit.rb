module Bankserv
  module Transmission::UserSet
  
    class Debit < Set
      
      before_save :decorate_records
    
      def self.generate
        set = self.new
      
        Bankserv::Debit.unprocessed.group_by(&:batch_id).each do |batch_id, debit_order|
        
        end
      end
    
      def self.has_work?
        Bankserv::Debit.has_work?
      end
      
      def self.create_sets  
        if Bankserv::Debit.unprocessed.count > 0
          set = self.new
          set.build_batches
          set.build_header
          # set.build_trailer
          set
        end
      end
      
      def build_header
        record_data = Absa::H2h::Transmission::Eft.record_type('header').template_options
        record_data.merge!(
          rec_id: '001',
          bankserv_user_code: 'RC UC',
          first_sequence_number: transactions.first.data[:user_sequence_number],
          last_sequence_number: transactions.last.data[:user_sequence_number],
          bankserv_creation_date: Time.now.strftime("%y%m%d"),
          bankserv_purge_date: "123123", #Equal to or greater than the last action date of the transactions
          first_action_date: "123123", #Equal to the transactions earliest action date 
          last_action_date: "123123", #Equal to the latest transaction date in user set
          first_sequence_number: "1", #Sequentially assigned per bankserv user code per transmission date
          user_generation_number: "2", #Equal to the last accepted user gen number + 1
          type_of_service: "SAMEDAY", # See document for diff types
        )
        
        self.records << Record.new(record_type: "header", data: record_data)
      end
      
      def build_trailer
        record_data = Absa::H2h::Transmission::Eft.record_type('trailer').template_options
        record_data.merge!(
          rec_id: '001',
          bankserv_user_code: 'RC UC',
          first_sequence_number: self.records.where(type: "header").first.data[:first_sequence_number],
          last_sequence_number: self.records.where(type: "contra").last.data[:user_sequence_number],
          first_action_date: "123123", #Equal to the transactions earliest action date 
          last_action_date: "123123", #Equal to the latest transaction date in user set
          no_debit_records: transactions.count,
          no_credit_records: 0,
          no_contra_records: self.records.where(type: "contra").count,
          total_debit_value: transactions.map(&:amount).map(&:to_i).inject(&:+),
          first_sequence_number: "1", #Sequentially assigned per bankserv user code per transmission date
          user_generation_number: "2", #Equal to the last accepted user gen number + 1
          type_of_service: "SAMEDAY", # See document for diff types
        )
        
        self.records << Record.new(type: "header", data: record_data)
      end
      
      def user_sequence_number
        transactions.count + 1
      end
      
      def transactions
        records.select {|rec| !(["header", "trailer"].include? rec.record_type)  }
      end
      
      def header
        self.records.where(record_type: "header").first
      end
      
      def trailer
        self.records.where(record_type: "trailer").first
      end
      
      def build_batches
        Bankserv::Debit.unprocessed.group_by(&:batch_id).each do |batch_id, debit_order|
          debit_order.select { |debit| debit.standard? }.each do |standard|
            self.build_transaction standard
          end
          
          debit_order.select { |debit| !debit.standard? }.each {|contra| self.build_transaction contra }
        end
      end
      
      def build_transaction(debit)
        if debit.standard?
          record_data = Absa::H2h::Transmission::Eft.record_type('standard_record').template_options
        else
          record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options
        end
        
        record_data.merge!(
          rec_id: "001",
          # user_branch: "RC",
          #           user_nominated_account: "RC Franchise acc",
          #           user_code: "RC UC",
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
        
        self.records << Record.new(record_type: debit.record_type + "_record", data: record_data)
      end
      
      private
      
      def decorate_records
        records.each do |record|
          record.data.merge(
            bankserv_record_identifier: 50,
            user_branch: "RC",
            user_nominated_account: "RC Franchise acc",
            user_code: "RC UC",
          )
        end
      end
    end
  end
end
