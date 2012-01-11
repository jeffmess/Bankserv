module Helpers
  def tear_it_down
    Bankserv::Document.delete_all
    Bankserv::Set.delete_all
    Bankserv::Record.delete_all
    Bankserv::AccountHolderVerification.delete_all
    Bankserv::Debit.delete_all
  end
end