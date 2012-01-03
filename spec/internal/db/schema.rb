ActiveRecord::Schema.define do
  create_table(:bankserv_account_holder_verification, :force => true) do |t|
    t.string :name
    t.text   :content
    t.timestamps
  end
end