module Bankserv
  
  module Transmission::UserSet
  
    class EftRedirect < Set
      
      def process
        transactions.each do |transaction|
          Bankserv::Eft.for_internal_reference(transaction.reference).first.process_response(transaction.data.merge(response_status: 'redirect'))
        end
      end
     
    end
   
  end
  
end