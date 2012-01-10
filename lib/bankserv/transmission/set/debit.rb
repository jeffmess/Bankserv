module Bankserv
  module Transmission::UserSet
  
    class Debit < Set
      
      before_save :decorate_header, :decorate_trailer
    
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
          set.build_header
          set.build_batches
          set.build_trailer
          set
        end
      end
      
      def user_sequence_number
        transactions.count + 1
      end
      
      def transactions
        records.select {|rec| !(["header", "trailer"].include? rec.record_type)  }
      end
      
      def header
        records.select {|rec| rec.record_type == "header" }.first
      end
      
      def trailer
        records.select {|rec| rec.record_type == "trailer" }.first
      end
      
      def build_header
        record_data = Absa::H2h::Transmission::Eft.record_type('header').template_options
        record_data.merge!(
          rec_id: '001',
          bankserv_creation_date: Time.now.strftime("%y%m%d"),
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
          no_credit_records: 0,
          first_sequence_number: "1", #Sequentially assigned per bankserv user code per transmission date
          user_generation_number: "2", #Equal to the last accepted user gen number + 1
          type_of_service: "SAMEDAY", # See document for diff types
        )
        
        self.records << Record.new(record_type: "trailer", data: record_data)
      end
      
      def build_batches
        Bankserv::Debit.unprocessed.group_by(&:batch_id).each do |batch_id, debit_order|
          standard_records = debit_order.select { |debit| debit.standard? }.each do |transaction|
            self.build_standard transaction
          end
          
          debit_order.select { |debit| !debit.standard? }.each {|transaction| self.build_contra transaction }
          
        end
      end
      
      def build_standard(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('standard_record').template_options
        
        record_data.merge!(
          rec_id: "001",
          user_sequence_number: user_sequence_number,
          bankserv_record_identifier: 50,
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: transaction.bank_account.account_number,
          type_of_account: transaction.bank_account.account_type,
          amount: transaction.amount,
          action_date: transaction.action_date,
          entry_class: 41,
          tax_code: 0,
          user_ref: transaction.user_reference,
          homing_account_name: transaction.bank_account.account_name,
          non_standard_homing_account_number: ''
        )
        
        self.records << Record.new(record_type: transaction.record_type + "_record", data: record_data)
      end
      
      def build_contra(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options
        
        record_data.merge!(
          rec_id: "001",
          user_sequence_number: user_sequence_number,
          bankserv_record_identifier: 52,
          user_branch: transaction.bank_account.branch_code,
          user_nominated_account: transaction.bank_account.account_number,
          user_code: "XXXXXX",
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: transaction.bank_account.account_number,
          type_of_account: 1,
          amount: transaction.amount,
          action_date: transaction.action_date,
          entry_class: 10,
          user_ref: transaction.user_reference,
        )
        
        self.records << Record.new(record_type: transaction.record_type + "_record", data: record_data)
      end
      
      def first_action_date
        fad = Date.today
        transactions.map(&:data).each do |hash|
          first = Date.strptime(hash[:action_date], "%Y-%m-%d")
          fad = first if first < fad
        end
        fad.strftime("%y%m%d")
      end
      
      def last_action_date
        lad = Date.today
        transactions.map(&:data).each do |hash|
          last = Date.strptime(hash[:action_date], "%Y-%m-%d")
          lad = last if last < lad
        end
        lad.strftime("%y%m%d")
      end
      
      def total_debit_value
        sum = 0
        transactions.map(&:data).map {|x| sum += x[:amount]}
        sum
      end
      
      private
      
      def decorate_header
        header.data.merge(
          bankserv_user_code: 'RC UC',
          first_sequence_number: transactions.first.data[:user_sequence_number],
          last_sequence_number: transactions.last.data[:user_sequence_number],
          bankserv_purge_date: self.last_action_date,
          first_action_date: self.first_action_date,
          last_action_date: self.last_action_date,
        )
      end
      
      def decorate_trailer
        trailer.data.merge(
          bankserv_user_code: 'RC UC',
          first_sequence_number: transactions.first.data[:user_sequence_number],
          last_sequence_number: transactions.last.data[:user_sequence_number],
          first_action_date: self.first_action_date,
          last_action_date: self.last_action_date,
          no_debit_records: transactions.count,
          no_contra_records: self.records.where(record_type: "contra").count,
          total_debit_value: self.total_debit_value,
        )
      end
    end
  end
end
