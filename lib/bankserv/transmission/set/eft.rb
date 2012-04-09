module Bankserv
  module Transmission::UserSet
  
    class Eft < Set
      
      before_save :decorate_records, :decorate_header, :decorate_trailer
      
      attr_accessor :type_of_service, :account_type_correct, :accepted_report
      
      def self.has_work?
        class_type.has_work?
      end
      
      def self.has_test_work?
        class_type.has_test_work?
      end
      
      def self.unprocessed_efts(rec_status)
        if rec_status == "L"
          self.class_type.unprocessed.select{|item| not item.request.test?}
        else
          self.class_type.unprocessed.select{|item| item.request.test?}
        end
      end
      
      def self.generate(options = {})
        efts = self.unprocessed_efts(options[:rec_status])
        
        if efts.count > 0
          set = self.new
          set.type_of_service = efts.first.request.data[:type_of_service]
          set.accepted_report = efts.first.request.data[:accepted_report] || ""
          set.account_type_correct = efts.first.request.data[:account_type_correct] || ""
          set.build_header
          set.build_batches(options[:rec_status])
          set.build_trailer
          set
        end
      end
      
      def set_type
        "eft"
      end
      
      def short_date(date)        
        date = Date.strptime(date, "%Y-%m-%d")
        date.strftime("%y%m%d")
      end
      
      def self.last_sequence_number_today
        if last = Record.where("date(created_at) = ? AND record_type = 'standard_record'", Date.today).last
          document = last.set.get_document
          raise "Cannot determine sequence number" if ((document) && (document.reply_status != 'ACCEPTED'))
        end
        
        last.nil? ? 0 : last.data[:user_sequence_number].to_i
      end
      
      def self.user_sequence_number(transactions)
        # (Bankserv::Configuration.eft_sequence_number + transactions.count).to_s
        (Bankserv::Transmission::UserSet::Eft.last_sequence_number_today + transactions.count + 1).to_s
      end
      
      def user_sequence_number
        Bankserv::Transmission::UserSet::Eft.user_sequence_number(transactions)
      end
      
      def contra_records
        records.where(record_type: "contra_record")
      end
      
      def standard_records
        records.where(record_type: "standard_record")
      end
      
      def get_user_generation_number
        Bankserv::Configuration.reserve_user_generation_number!.to_s #Equal to the last accepted user gen number + 1
      end
      
      def get_eft_sequence_number(number=nil)
        Bankserv::Transmission::UserSet::Eft.get_eft_sequence_number(number)
      end
      
      def self.get_eft_sequence_number(number=nil)
        Bankserv::Configuration.reserve_eft_sequence_number!(number).to_s
      end
      
      def build_header(options = {})
        self.generation_number = options[:user_generation_number] || get_user_generation_number
        record_data = Absa::H2h::Transmission::Eft.record_type('header').template_options
        eft_sequence_number = options[:first_sequence_number] || get_eft_sequence_number
        
        record_data.merge!(
          rec_id: rec_id,
          bankserv_creation_date: Time.now.strftime("%y%m%d"),
          first_sequence_number: eft_sequence_number,
          user_generation_number: generation_number,
          type_of_service: @type_of_service,
          accepted_report: @accepted_report.nil? ? "" : @accepted_report,
          account_type_correct: @account_type_correct
        )
        
        records.build(record_type: "header", data: record_data)
      end
      
      def build_trailer(options = {})   
        record_data = Absa::H2h::Transmission::Eft.record_type('trailer').template_options
        records.build(record_type: "trailer", data: record_data.merge(rec_id: rec_id))
      end
      
      def build_batches(rec_status)
        efts = self.class.unprocessed_efts(rec_status)
        
        efts.group_by(&:batch_id).each do |batch_id, eft|
          eft.select(&:standard?).each{|t| build_standard t}
          eft.select(&:contra?).each{|t| build_contra t}
        end
      end
      
      def build_standard(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('standard_record').template_options
        homing_account_number = transaction.bank_account.account_number.to_i.to_s
        homing_branch_code = transaction.bank_account.branch_code.to_i.to_s
        
        record_data.merge!(
          rec_id: rec_id,
          user_sequence_number: user_sequence_number,
          user_nominated_account: transaction.contra_bank_details.account_number, 
          user_branch: transaction.contra_bank_details.branch_code, 
          user_code: Bankserv::Configuration.active.user_code,
          bankserv_record_identifier: standard_bankserv_record_identifier,
          homing_branch: homing_branch_code,
          homing_account_number: homing_account_number.length <= 11 ? homing_account_number : "0",
          type_of_account: transaction.bank_account.account_type_id,
          amount: transaction.amount.to_s,
          action_date: short_date(transaction.action_date),
          entry_class: standard_entry_class,
          tax_code: "0",
          user_ref: transaction.formatted_user_ref,
          homing_account_name: transaction.bank_account.account_name,
          non_standard_homing_account_number: homing_account_number.length > 11 ? homing_account_number : "0"
        )
        
        records.build(record_type: transaction.record_type + "_record", data: record_data)
      end
      
      def build_contra(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options
        
        record_data.merge!(
          rec_id: rec_id,
          user_sequence_number: user_sequence_number,
          bankserv_record_identifier: contra_bankserv_record_identifier,
          user_branch: transaction.bank_account.branch_code,
          user_nominated_account: transaction.bank_account.account_number.to_i.to_s,
          user_code: Bankserv::Configuration.active.user_code,
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: transaction.bank_account.account_number,
          type_of_account: "1",
          amount: transaction.amount.to_s,
          action_date: short_date(transaction.action_date),
          entry_class: "10",
          user_ref: transaction.formatted_user_ref
        )
        
        records.build(record_type: transaction.record_type + "_record", data: record_data)
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
      
      def hash_total_of_homing_account_numbers
        hash_total = 0

        transactions.each do |transaction|
          hash_total += transaction.data[:homing_account_number].to_i
          hash_total += transaction.data[:non_standard_homing_account_number].to_i if transaction.record_type == "standard_record"
        end

        hash_total.to_s.reverse[0,12].reverse.to_i
      end
      
      def total_debit_value
        debit_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def total_credit_value
        credit_records.inject(0) { |sum, record| sum + record.data[:amount].to_i }
      end
      
      def no_debit_records
        debit_records.count.to_s
      end
      
      def no_credit_records
        credit_records.count.to_s
      end
      
      private
      
      def decorate_header
        header.data[:bankserv_user_code] = Bankserv::Configuration.active.user_code
        header.data[:bankserv_purge_date] = purge_date
        header.data[:first_action_date] = first_action_date
        header.data[:last_action_date] = last_action_date
        header.save!
      end
      
      def decorate_trailer  
        trailer.data[:bankserv_user_code] = Bankserv::Configuration.active.user_code
        trailer.data[:first_sequence_number] = transactions.first.data[:user_sequence_number].to_s
        trailer.data[:last_sequence_number] = transactions.last.data[:user_sequence_number].to_s
        trailer.data[:first_action_date] = first_action_date
        trailer.data[:last_action_date] = last_action_date
        trailer.data[:no_debit_records] = no_debit_records
        trailer.data[:no_credit_records] = no_credit_records
        trailer.data[:no_contra_records] = records.where(record_type: "contra_record").count.to_s
        trailer.data[:total_debit_value] = total_debit_value.to_s
        trailer.data[:total_credit_value] = total_debit_value.to_s
        trailer.data[:hash_total_of_homing_account_numbers] = hash_total_of_homing_account_numbers.to_s
        trailer.save!
      end
    end
  end
end
