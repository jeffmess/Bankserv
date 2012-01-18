module Bankserv
  
  module Transmission::UserSet
  
    class EftUnpaid < Set
      
      def process
        transactions.each do |transaction|
          eft = Bankserv::Eft.for_internal_reference(transaction.reference).first
          eft.process_response(transaction.data.merge(response_status: 'unpaid')) if eft
        end
      end
     
    end
   
  end
  
end