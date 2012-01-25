module Bankserv
  
  module Transmission::UserSet
  
    class Reply < Set
      
      def process
        document = nil
        
        transactions.each do |transaction|
          case transaction.record_type
          when "transmission_status"
            document = Bankserv::Document.where(type: 'input', transmission_number: transaction.data[:transmission_number]).first
            document.reply_status = transaction.data[:transmission_status]
            document.save!
          when "transmission_rejected_reason"
            document.error = {
              code: transaction.data[:error_code],
              message: transaction.data[:error_message]
            }
            
            document.save!
          when "eft_status"
            set = Bankserv::Set.where(generation_number: transaction.data[:user_code_generation_number]).first
            set.reply_status = transaction.data[:user_set_status]
            set.save!
          when "accepted_report_reply"
            # what do we do here.. what is an accepted report reply?
          when "rejected_message"
            set = Bankserv::Set.where(generation_number: transaction.data[:user_code_generation_number]).first
            record = set.transactions.select{|rec| rec.data[:user_sequence_number] == transaction.data[:user_sequence_number]}.first
            
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