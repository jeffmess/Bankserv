module Bankserv
  
  module Transmission::UserSet
  
    class AccountHolderVerificationOutput < Set
      
      def process
        transactions.each do |transaction|
          Bankserv::AccountHolderVerification.for_reference(transaction.reference).first.process_response(transaction.data)
        end
      end
     
    end
   
  end
  
end