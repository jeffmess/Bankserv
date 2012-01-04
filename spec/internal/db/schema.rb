ActiveRecord::Schema.define do
  
  create_table(:bankserv_internal_account_details, :force => true) do |t|
    t.integer :id
    t.string :status, :default => 'unprocessed'
    t.timestamps
    t.string :rec_id
    t.string :rec_status
    t.string :seq_no
    t.string :account_number
    t.string :id_number
    t.string :initials
    t.string :surname
    t.string :return_code_1
    t.string :return_code_2
    t.string :return_code_3
    t.string :return_code_4
    t.string :user_ref
  end
  
  create_table(:bankserv_external_account_details, :force => true) do |t|
    t.integer :id
    t.string :status, :default => 'unprocessed'
    t.timestamps
    t.string :rec_id
    t.string :rec_status
    t.string :seq_no
    t.string :account_number
    t.string :id_number
    t.string :initials
    t.string :surname
    t.string :return_code_1
    t.string :return_code_2
    t.string :return_code_3
    t.string :return_code_4
    t.string :user_ref
    t.string :branch_code
    t.string :originating_bank
    t.string :ld_code
    t.string :return_code_5
    t.string :return_code_6
    t.string :return_code_7
    t.string :return_code_8
    t.string :return_code_9
    t.string :return_code_10
  end
end