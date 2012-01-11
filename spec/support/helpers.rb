module Helpers
  def tear_it_down
    Bankserv::Configuration.delete_all
    Bankserv::Request.delete_all
  
    Bankserv::AccountHolderVerification.delete_all
    Bankserv::Debit.delete_all
    Bankserv::Credit.delete_all
    
    Bankserv::Document.delete_all
    Bankserv::Set.delete_all
    Bankserv::Record.delete_all
  end
end