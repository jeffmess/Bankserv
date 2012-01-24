module Bankserv
  
  module Transmission::UserSet
  
    class Reply < Set
      
      def process
        transactions.each do |transaction|
          case transaction.record_type
          when "transmission_status"
            document = Bankserv::Document.where(type: 'input', transmission_number: transaction.data[:transmission_number]).first
            document.reply_status = transaction.data[:transmission_status]
            document.save!
          when "transmission_rejected_reason"
            
          when "eft_status"
            set = Bankserv::Set.where(generation_number: transaction.data[:user_code_generation_number]).first
            set.reply_status = transaction.data[:user_set_status]
            set.save!
          when "accepted_report_reply"
            
          when "rejected_message"
            
          end
        end
      end
     
    end
   
  end
  
end