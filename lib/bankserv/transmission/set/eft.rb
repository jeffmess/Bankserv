module Bankserv
  module Transmission::UserSet

    class Eft < Set

      before_save :set_sequence_numbers, :decorate_records, :decorate_header, :decorate_trailer

      attr_accessor :type_of_service, :account_type_correct, :accepted_report

      def self.has_work?
        class_type.has_work?
      end

      def self.has_test_work?
        class_type.has_test_work?
      end

      def self.unprocessed_efts(rec_status)
        if rec_status == "L"
          # include here?

          self.class_type.includes(:request, :bank_account).unprocessed.select{|item| not item.request.test?}
          #self.class_type.unprocessed.select{|item| not item.request.test?}
        else
          self.class_type.unprocessed.select{|item| item.request.test?}
        end
      end

      def self.generate(options = {})
        efts = self.unprocessed_efts(options[:rec_status])

        if efts.count > 0
          set = self.new
          set.type_of_service = efts.first.request.data[:type_of_service]
          set.accepted_report = efts.first.request.data[:accepted_report] || "Y"
          set.account_type_correct = efts.first.request.data[:account_type_correct] || "Y"
          set.build_batches(efts)
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

      def contra_records
        records.where(record_type: "contra_record")
      end

      def standard_records
        records.where(record_type: "standard_record")
      end

      def get_user_generation_number
        bankserv_service.reserve_generation_number!.to_s #Equal to the last accepted user gen number + 1
        #gen = Bankserv::DebitService.active.last.reserve_generation_number!.to_s unless Bankserv::DebitService.active.blank?
        #gen = Bankserv::CreditService.active.last.reserve_generation_number!.to_s unless Bankserv::CreditService.active.blank?
        #gen
      end

      def build_header(options = {})
        self.generation_number = options[:user_generation_number] || get_user_generation_number
        record_data = Absa::H2h::Transmission::Eft.record_type('header').template_options

        record_data.merge!(
          rec_id: rec_id,
          bankserv_creation_date: Time.now.strftime("%y%m%d"),
          user_generation_number: generation_number,
          type_of_service: @type_of_service,
          accepted_report: @accepted_report.nil? ? "" : @accepted_report,
          account_type_correct: @account_type_correct
        )

        record_data.merge!(first_sequence_number: options[:first_sequence_number]) if options[:first_sequence_number]

        records.build(record_type: "header", data: record_data)
      end

      def build_trailer(options = {})
        record_data = Absa::H2h::Transmission::Eft.record_type('trailer').template_options
        records.build(record_type: "trailer", data: record_data.merge(rec_id: rec_id))
      end

      def build_standard(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('standard_record').template_options
        homing_account_number = transaction.bank_account.account_number.to_i.to_s
        homing_branch_code = transaction.bank_account.branch_code.to_i.to_s

        record_data.merge!(
          rec_id: rec_id,
          user_nominated_account: transaction.contra_bank_details.account_number,
          user_branch: transaction.contra_bank_details.branch_code,
          user_code: bankserv_service.config[:user_code],
          bankserv_record_identifier: standard_bankserv_record_identifier,
          homing_branch: homing_branch_code,
          homing_account_number: homing_account_number.length <= 11 ? homing_account_number : "0",
          type_of_account: transaction.bank_account.account_type_id,
          amount: transaction.amount.to_s,
          action_date: short_date(transaction.action_date),
          entry_class: standard_entry_class,
          tax_code: "0",
          user_ref: transaction.formatted_user_ref,
          homing_account_name: transaction.bank_account.account_holder,
          non_standard_homing_account_number: homing_account_number.length > 11 ? homing_account_number : "0"
        )

        records.build(record_type: transaction.record_type + "_record", data: record_data, sourceable: transaction)
      end

      def build_contra(transaction)
        record_data = Absa::H2h::Transmission::Eft.record_type('contra_record').template_options

        record_data.merge!(
          rec_id: rec_id,
          bankserv_record_identifier: contra_bankserv_record_identifier,
          user_branch: transaction.bank_account.branch_code,
          user_nominated_account: transaction.bank_account.account_number.to_i.to_s,
          user_code: bankserv_service.config[:user_code],
          homing_branch: transaction.bank_account.branch_code,
          homing_account_number: transaction.bank_account.account_number,
          type_of_account: "1",
          amount: transaction.amount.to_s,
          action_date: short_date(transaction.action_date),
          entry_class: "10",
          user_ref: transaction.formatted_user_ref
        )

        records.build(record_type: transaction.record_type + "_record", data: record_data, sourceable: transaction)
      end

      def first_action_date
        transactions.min_by{|t| t.data[:action_date]}.data[:action_date]
      end

      def last_action_date
        transactions.max_by{|t| t.data[:action_date]}.data[:action_date]
      end

      def purge_date
        last_action_date
      end

      def hash_total_of_homing_account_numbers
        hash_total = 0

        transactions.each do |transaction|
          hash_total += transaction.data[:homing_account_number].to_i
          hash_total += transaction.data[:non_standard_homing_account_number].reverse[0,11].reverse.to_i if transaction.record_type == "standard_record"
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

      def set_sequence_numbers
        sequence_number = (header.data[:first_sequence_number] || bankserv_service.reserve_sequence_number!).to_i

        header.data[:first_sequence_number] = sequence_number.to_s
        trailer.data[:first_sequence_number] = sequence_number.to_s

        transactions.each do |record|
          record.data[:user_sequence_number] = sequence_number.to_s
          sequence_number += 1
        end

        trailer.data[:last_sequence_number] = (sequence_number - 1).to_s

        bankserv_service.reserve_sequence_number!(sequence_number - 1)
      end

      def decorate_header
        header.data[:bankserv_user_code] = bankserv_service.config[:user_code]
        header.data[:bankserv_purge_date] = purge_date
        header.data[:first_action_date] = first_action_date
        header.data[:last_action_date] = last_action_date
        header.save!
      end

      def decorate_trailer
        trailer.data[:bankserv_user_code] = header.data[:bankserv_user_code]
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
# 28905810181. Got 402890581018.
