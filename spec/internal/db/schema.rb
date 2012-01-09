ActiveRecord::Schema.define do
  
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
  end
  
  create_table :bankserv_account_holder_verifications, :force => true do |t|
    t.boolean :internal, :default => false
    t.references :bankserv_bank_account
    t.boolean :processed, :default => false
    t.string :status
    t.text :response
    t.string :user_ref
    t.timestamps
  end
  
  create_table :bankserv_debits, :force => true do |t|
    t.string :record_type
    t.integer :amount
    t.string :action_date
    t.references :bankserv_bank_account
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
    t.integer :batch_id
    t.boolean :processed, :default => false
    t.string :status
    t.text :response
    t.string :user_ref
    t.timestamps
  end
  
  create_table :bankserv_documents, :force => true do |t|
    t.string :type
    t.boolean :processed, :default => false
    t.boolean :test, :default => false
  end
  
  create_table :bankserv_sets, :force => true do |t|
    t.references :document
    t.string :type
  end
  
  create_table :bankserv_records, :force => true do |t|
    t.references :set
    t.string :record_type
    t.text :data
  end
  
end