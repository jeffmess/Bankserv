module Bankserv
  
  module Transmission::UserSet
  
    class Reply < Set
      
      def process
        document = nil
        
        transactions.each do |transaction|
          case transaction.record_type
          when "transmission_status"
            document = Bankserv::InputDocument.for_transmission_number(transaction.data[:transmission_number])
            document.reply_status = transaction.data[:transmission_status]
            document.save!
          when "transmission_rejected_reason"
            document.error = {
              code: transaction.data[:error_code],
              message: transaction.data[:error_message]
            }
            
            document.save!
          when "eft_status"
            set = Bankserv::Set.for_generation_number(transaction.data[:user_code_generation_number])
            set.reply_status = transaction.data[:user_set_status]
            set.save!
          when "accepted_report_reply"
            # what do we do here.. what is an accepted report reply?
          when "rejected_message"
            set = Bankserv::Set.for_generation_number(transaction.data[:user_code_generation_number])
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