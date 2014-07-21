module Bankserv
  
  module Transmission::UserSet
  
    class Reply < Set
      
      def process
        input_document = Bankserv::InputDocument.for_user_ref(self.set.document.user_ref)
        #service = Bankserv::Service.active.select {|s| s.config[:user_code] == self.records.first.data[:user_code]}.last
        service = Bankserv::Service.active.select {|s| s.client_code.to_i.to_s == self.records.first.data[:user_code]}.last

        rejections = []
        records_with_errors = []

        transactions.each do |transaction|
          case transaction.record_type
          when "transmission_status"
            # document = Bankserv::InputDocument.for_transmission_number(transaction.data[:transmission_number])
            # document = Bankserv::InputDocument.for_user_ref(transaction.data[:th_for_use_of_ld_user])
            input_document.reply_status = transaction.data[:transmission_status]
            input_document.save!

            if input_document.accepted?
              Bankserv::Service.for_client_code(input_document.client_code).active.each do |service|
                service.update_transmission_number!
              end
            end
            
          when "transmission_rejected_reason"
            input_document.error = {
              code: transaction.data[:error_code],
              message: transaction.data[:error_message]
            }
            
            input_document.save!
          when "ahv_status"
            # set = document.set_with_generation_number(transaction.data[:user_code_generation_number])
            set = input_document.set_with_dept_code(transaction.data[:user_code_generation_number])
            set.reply_status = transaction.data[:user_set_status]
            set.save!
          when "eft_status"
            set = input_document.set_with_generation_number(transaction.data[:user_code_generation_number])
            set.reply_status = transaction.data[:user_set_status]
            set.save!
          when "accepted_report_reply"
            # what do we do here.. what is an accepted report reply?
            if transaction.data[:accepted_report_transaction][4,2] == "12" # Contra record
              if service.is_a? Bankserv::CreditService
                user_ref = transaction.data[:accepted_report_transaction].match(/CONTRA([0-9]*)/)[1]

                request_id = Bankserv::Credit.where(user_ref: user_ref)[0].bankserv_request_id
                Bankserv::Credit.where(bankserv_request_id: request_id).each do |credit|
                  credit.accept!
                end
              end
            end
          when "rejected_message"
            rejections << transaction

            if transaction.data[:user_sequence_number].to_i > 0
              set = input_document.set_with_generation_number(transaction.data[:user_code_generation_number])
              record = set.record_with_sequence_number(transaction.data[:user_sequence_number])

              if record.error.nil?
                record.error = [{
                  code: transaction.data[:error_code],
                  message: transaction.data[:error_message]
                }]
              else
                record.error << {
                  code: transaction.data[:error_code],
                  message: transaction.data[:error_message]
                }
              end

              record.save!

              if service.is_a? Bankserv::CreditService
                next if set.contra_records.empty?

                set = input_document.set_with_generation_number(transaction.data[:user_code_generation_number])
                user_ref = set.contra_records.first.reference.match(/CONTRA([0-9]*)/)[1]
                request_id = Bankserv::Credit.where(user_ref: user_ref)[0].bankserv_request_id

                Bankserv::Credit.where(bankserv_request_id: request_id).each do |credit|
                  credit.renew!
                end
              end
              
              records_with_errors << record
            else
              # Only 1 error due to a transaction above it failing. We can requeue this transaction to be processed again

              if service.is_a? Bankserv::CreditService
                set = input_document.set_with_generation_number(transaction.data[:user_code_generation_number])
                user_ref = set.contra_records.first.reference.match(/CONTRA([0-9]*)/)[1]
                request_id = Bankserv::Credit.where(user_ref: user_ref)[0].bankserv_request_id

                Bankserv::Credit.where(bankserv_request_id: request_id).each do |credit|
                  credit.renew!
                end
              end
            end
          end
        end

        unless rejections.empty?
          service.config[:generation_number] = rejections.first.data[:user_code_generation_number].to_i
          service.config[:sequence_number] = rejections.first.data[:user_sequence_number].to_i
          service.save!
        end

        records_with_errors.uniq.each do |rwe|
          #puts rwe.error.inspect
        end
      end
    end
  end
end
