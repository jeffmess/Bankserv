module Bankserv
  
  module Transmission::UserSet
  
    class EftUnpaid < Set
      
      def process
        transactions.each do |transaction|
          Bankserv::Eft.for_internal_reference(transaction.reference).first.process_response(transaction.data.merge(response_status: 'unpaid'))
        end
      end
     
    end
   
  end
  
end