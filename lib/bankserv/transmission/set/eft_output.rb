module Bankserv
  
  module Transmission::UserSet
  
    class EftOutput < Set
      
      def process
        service = Bankserv::Service.active.select {|s| s.config[:user_code] == self.records.first.data[:bankserv_user_code]}.last

        if !service.nil? && service.is_a?(Bankserv::CreditService)
          self.sets.each do |set|
            set.transactions.each do |trans|

              ref = trans.reference.gsub(service.config[:client_abbreviated_name], "")
              
              credits = Bankserv::Credit.where(record_type: 'standard', action_date: trans.data[:transmission_date].to_date, 
                status: ['accepted', 'pending', 'warning', 'rejected'], amount: trans.data[:amount].to_i).where('lower(user_ref) = ?', ref.downcase).select do |credit|

                branch_code = if trans.data[:homing_branch_code] == "0" then "" else trans.data[:homing_branch_code] end

                credit.bank_account.account_number == trans.data[:homing_account_number] &&
                credit.bank_account.branch_code == branch_code &&
                credit.bank_account.account_name.downcase == trans.data[:homing_account_name].downcase
              end

              rejection_reason_description = Absa::H2h::Eft::RejectionCode.reason_for_code(trans.data[:rejection_reason]),
              rejection_qualifier_description = Absa::H2h::Eft::RejectionCode.qualifier_for_code(trans.data[:rejection_qualifier])

              credits.each do |credit|
                request_credits = Bankserv::Credit.where(bankserv_request_id: credit.bankserv_request_id)
                request_credits.each do |c|
                  c.update_attributes!({
                    status: 'rejected',
                    response: [{
                      code: rejection_reason_description,
                      message: rejection_qualifier_description
                    }]
                  })
                end
              end
            end
          end
        else
          sets.each{|s| s.process}
        end
      end
    end
  end
end
