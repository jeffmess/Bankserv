module Bankserv
  
  module Transmission::UserSet
  
    class EftUnpaid < Set
      
      def process
        transactions.each do |transaction|
          Bankserv::Eft.for_reference(transaction.reference).first.process_response(transaction.data)
        end
      end
     
    end
   
  end
  
end