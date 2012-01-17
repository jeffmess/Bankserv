ActiveRecord::Schema.define do
  
  create_table :bankserv_configurations, :force => true do |t|
    t.boolean :active, :default => false
    t.string :client_code
    t.string :client_name
    t.string :client_abbreviated_name
    t.string :user_code
    t.integer :user_generation_number
    t.string :department_code
    t.string :internal_branch_code
    t.timestamps
  end
  
  create_table :bankserv_requests, :force => true do |t|
    t.string :type
    t.text :data
    t.boolean :processed, :default => false
    t.string :status
    t.text :response
    t.timestamps
  end
  
  create_table :bankserv_bank_accounts, :force => true do |t|
    t.string :branch_code
    t.string :account_number
    t.string :account_type
    t.string :initials
    t.string :account_name
    t.string :id_number
    t.timestamps
  end
  
  create_table :bankserv_account_holder_verifications, :force => true do |t|
    t.boolean :internal, :default => false
    t.references :bankserv_bank_account
    t.references :bankserv_request
    t.string :status, :default => "new"
    t.text :response
    t.string :user_ref
    t.timestamps
  end
  
  create_table :bankserv_debits, :force => true do |t|
    t.string :record_type
    t.integer :amount
    t.string :action_date
    t.references :bankserv_bank_account
    t.references :bankserv_request
    t.integer :batch_id
    t.boolean :processed, :default => false
    t.string :status
    t.text :response
    t.string :user_ref
    t.timestamps
  end
  
  create_table :bankserv_credits, :force => true do |t|
    t.string :record_type
    t.integer :amount
    t.string :action_date
    t.references :bankserv_bank_account
    t.references :bankserv_request
    t.integer :batch_id
    t.boolean :processed, :default => false
    t.string :status
    t.text :response
    t.string :user_ref
    t.timestamps
  end
  
  create_table :bankserv_documents, :force => true do |t|
    t.string :type
    t.references :set
    t.boolean :processed, :default => false
    t.boolean :test, :default => false
    t.timestamps
  end
  
  create_table :bankserv_sets, :force => true do |t|
    t.references :set
    t.string :type
    t.timestamps
  end
  
  create_table :bankserv_records, :force => true do |t|
    t.references :set
    t.string :record_type
    t.string :reference
    t.text :data
    t.timestamps
  end
  
end