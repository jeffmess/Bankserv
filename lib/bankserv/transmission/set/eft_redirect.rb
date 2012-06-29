module Bankserv
  
  module Transmission::UserSet
  
    class EftRedirect < Set
      
      def process
        transactions.each do |transaction|
          eft = Bankserv::Eft.for_reference(transaction.reference).first
          eft.process_response(transaction.data.merge(response_status: 'redirect')) if eft
        end
      end
     
    end
   
  end
  
end