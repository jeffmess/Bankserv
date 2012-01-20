module Bankserv
  module Transmission::UserSet
  
    class Debit < Set
      
      before_save :decorate_records, :decorate_header, :decorate_trailer
      
      attr_accessor :type_of_service, :account_type_correct, :accepted_report
      
      def to_hash
        {
          type: "eft",
          data: [
            {type: 'header', data: header.data},
            transactions.collect{|rec| {type: rec.record_type, data: rec.data}},
            {type: 'trailer', data: trailer.data}
          ].flatten
        }
      end
    
      def self.has_work?
        Bankserv::Debit.has_work?
      end
      
      def self.generate
        if Bankserv::Debit.unprocessed.count > 0
          set = self.new
          set.type_of_service = Bankserv::Debit.unprocessed.first.request.data[:type_of_service]
          set.accepted_report = Bankserv::Debit.unprocessed.first.request.data[:accepted_report] || ""
          set.account_type_correct = Bankserv::Debit.unprocessed.first.request.data[:account_type_correct] || ""
          set.build_header
          set.build_batches
          set.build_trailer
          set
        end
      end
      
      def short_date(date)        
        date = Date.strptime(date, "%Y-%m-%d")
        date.strftime("%y%m%d")
      end
      
      def last_sequence_number_today
        last = Record.where("date(created_at) = ? AND record_type = 'standard_record'", Date.today).last
        last.nil? ? 0 : last.data[:user_sequence_number].to_i
      end
      
      def user_sequence_number
        (last_sequence_number_today + transactions.count + 1).to_s
      end
      
      def contra_records
        self.records.where(record_type: "contra_record")
      end
      
      def standard_records
        self.records.where(record_type: "standard_record")
      end
      
      def get_user_generation_number
        Bankserv::Configuration.reserve_user_generation_number!.to_s
      end
      
      def build_header
        record_data = Absa::H2h::Transmission::Eft.record_type('header').template_options
        
        record_data.merge!(
          rec_id: '001',
          bankserv_creation_date: Time.now.strftime("%y%m%d"),
          first_sequence_number: (last_sequence_number_today + 1).to_s,
          user_generation_number: self.get_user_generation_number, #Equal to the last accepted user gen number + 1
          type_of_service: @type_of_service,
          accepted_report: @accepted_report.nil? ? "" : @accepted_report,
          account_type_correct: @account_type_correct
        )
        
        self.records << Record.new(record_type: "header", data: record_data)
      end
      
      def build_trailer
        record_data = Absa::H2h::Transmission::Eft.record_type('trailer').template_options
        self.records << Record.new(record_type: "trailer", data: record_data.merge(rec_id: '001'))
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
        homing_account_number = transaction.bank_account.account_number.to_s
        
        record_data.merge!(
          rec_id: "001",
          user_sequence_number: user_sequence_number,
          user_nominated_account: transaction.contra_bank_details.account_number, 
          user_branch: transaction.contra_bank_details.branch_code, 
          user_code: Bankserv::Configuration.active.user_code,
          bankserv_record_identifier: "50",
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: homing_account_number.length <= 11 ? homing_account_number : "0",
          type_of_account: transaction.bank_account.account_type_id,
          amount: transaction.amount.to_s,
          action_date: self.short_date(transaction.action_date),
          entry_class: "44",
          tax_code: "0",
          user_ref: transaction.formatted_user_ref,
          homing_account_name: transaction.bank_account.account_name,
          non_standard_homing_account_number: homing_account_number.length > 11 ? homing_account_number : "0"
        )
        
        self.records << Record.new(record_type: transaction.record_type + "_record", data: record_data)
      end
      
      def build_contra(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options
        
        record_data.merge!(
          rec_id: "001",
          user_sequence_number: user_sequence_number,
          bankserv_record_identifier: "52",
          user_branch: transaction.bank_account.branch_code,
          user_nominated_account: transaction.bank_account.account_number,
          user_code: Bankserv::Configuration.active.user_code,
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: transaction.bank_account.account_number,
          type_of_account: "1",
          amount: transaction.amount.to_s,
          action_date: self.short_date(transaction.action_date),
          entry_class: "10",
          user_ref: transaction.formatted_user_ref
        )
        
        self.records << Record.new(record_type: transaction.record_type + "_record", data: record_data)
      end
      
      def first_action_date
        fad = Date.today
        transactions.map(&:data).each do |hash|
          first = Date.strptime(hash[:action_date], "%y%m%d")
          fad = first if first < fad
        end
        fad.strftime("%y%m%d")
      end
      
      def last_action_date
        lad = Date.today
        transactions.map(&:data).each do |hash|
          last = Date.strptime(hash[:action_date], "%y%m%d")
          lad = last if last < lad
        end
        lad = lad + 3.days
        lad.strftime("%y%m%d")
      end
      
      def purge_date
        date = Date.strptime("#{self.last_action_date}", "%y%m%d") + 4.days
        date.strftime("%y%m%d")
      end
      
      def total_debit_value
        standard_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def total_credit_value
        contra_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def hash_total_of_homing_account_numbers
        hash_total = 0

        self.transactions.each do |transaction|
          if transaction.record_type == "standard_record"
            hash_total += transaction.data[:homing_account_number].to_i + transaction.data[:non_standard_homing_account_number].to_i
          else
            hash_total += transaction.data[:homing_account_number].to_i
          end
        end

        hash_total.to_s.reverse[0,12].reverse.to_i
      end
      
      private
      
      def decorate_records
        self.records.each do |record|
          record[:data][:rec_status] = self.rec_status
          record.save!
        end
      end
      
      def decorate_header
        self.purge_date
        header.data[:bankserv_user_code] = Bankserv::Configuration.active.user_code
        # header.data[:first_sequence_number] = transactions.first.data[:user_sequence_number].to_s
        header.data[:bankserv_purge_date] = self.purge_date
        header.data[:first_action_date] = self.first_action_date
        header.data[:last_action_date] = self.last_action_date
        header.save!
      end
      
      def decorate_trailer          
        trailer.data[:bankserv_user_code] = Bankserv::Configuration.active.user_code
        trailer.data[:first_sequence_number] = transactions.first.data[:user_sequence_number].to_s
        trailer.data[:last_sequence_number] = transactions.last.data[:user_sequence_number].to_s
        trailer.data[:first_action_date] = self.first_action_date
        trailer.data[:last_action_date] = self.last_action_date
        trailer.data[:no_debit_records] = self.records.where(record_type: "standard_record").count.to_s
        trailer.data[:no_credit_records] = self.records.where(record_type: "contra_record").count.to_s
        trailer.data[:no_contra_records] = self.records.where(record_type: "contra_record").count.to_s
        trailer.data[:total_debit_value] = self.total_debit_value.to_s
        trailer.data[:total_credit_value] = self.total_debit_value.to_s
        trailer.data[:hash_total_of_homing_account_numbers] = self.hash_total_of_homing_account_numbers.to_s
        trailer.save!
      end
    end
  end
end
