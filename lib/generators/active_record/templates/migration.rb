class CreateBankservTables < ActiveRecord::Migration
  def self.change
    
    create_table :bankserv_configurations, :force => true do |t|
      t.boolean :active, :default => false
      t.string :client_code
      t.string :client_name
      t.string :user_code
      t.string :department_code
      t.timestamps
    end
    
    create_table :bankserv_requests do |t|
      t.string :type
      t.text :data
      t.boolean :processed, :default => false
      t.string :status
      t.text :response
      t.timestamps
    end
    
    create_table :bankserv_bank_accounts do |t|
      t.string :branch_code
      t.string :account_number
      t.string :account_type
      t.string :initials
      t.string :account_name
      t.string :id_number
      t.timestamps
    end
    
    create_table :bankserv_account_holder_verifications do |t|
      t.boolean :internal, :default => false
      t.references :bankserv_bank_account
      t.boolean :processed, :default => false
      t.string :status
      t.text :response
      t.string :user_ref
      t.timestamps
    end
    
    create_table :bankserv_debits do |t|
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
    
    create_table :bankserv_credits do |t|
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
    
    create_table :bankserv_documents do |t|
      t.string :type
      t.boolean :processed, :default => false
      t.boolean :test, :default => false
      t.timestamps
    end
    
    create_table :bankserv_sets do |t|
      t.references :document
      t.string :type
      t.timestamps
    end
    
    create_table :bankserv_records do |t|
      t.references :set
      t.string :record_type
      t.text :data
      t.timestamps
    end
    
  end

end