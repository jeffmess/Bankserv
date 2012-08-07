module Bankserv
  
  module Transmission::UserSet
  
    class Reply < Set
      
      def process
        input_document = Bankserv::InputDocument.for_user_ref(self.set.document.user_ref)
        
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
          when "rejected_message"
            if transaction.data[:user_sequence_number].to_i > 0
              set = input_document.set_with_generation_number(transaction.data[:user_code_generation_number])
              record = set.record_with_sequence_number(transaction.data[:user_sequence_number])
            
              record.error = {
                code: transaction.data[:error_code],
                message: transaction.data[:error_message]
              }

              record.save!
            end
          end
        end
      end
    end
  end
end