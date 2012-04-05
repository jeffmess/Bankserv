class CreateBankservTables < ActiveRecord::Migration
  def self.change
    
    create_table :bankserv_statements, :force => true do |t|
      t.boolean :processed, :default => false
      t.string :client_code
      t.text :data
      t.timestamps
    end
    
    create_table :bankserv_transactions, :force => true do |t|
      t.boolean :processed, :default => false
      t.string :client_code
      t.text :data
      t.references :bankserv_statement
      t.timestamps
    end
    
    create_table :bankserv_configurations, :force => true do |t|
      t.boolean :active, :default => false
      t.string :client_code
      t.string :client_name
      t.string :client_abbreviated_name
      t.string :user_code
      t.string :department_code
      t.integer :transmission_number
      t.integer :user_generation_number
      t.string :internal_branch_code
      t.boolean :live_env, :default => false
      t.timestamps
    end
    
    create_table :bankserv_requests do |t|
      t.string :type
      t.text :data
      t.boolean :processed, :default => false
      t.string :status
      t.text :response
      t.boolean :test, :default => false
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
      t.references :bankserv_request
      t.string :status, :default => "new"
      t.text :response
      t.string :user_ref
      t.string :internal_user_ref
      t.timestamps
    end
    
    create_table :bankserv_debits do |t|
      t.string :record_type
      t.integer :amount
      t.string :action_date
      t.references :bankserv_bank_account
      t.references :bankserv_request
      t.integer :batch_id
      t.string :status, :default => "new"
      t.text :response
      t.string :user_ref
      t.string :internal_user_ref
      t.timestamps
    end
    
    create_table :bankserv_credits do |t|
      t.string :record_type
      t.integer :amount
      t.string :action_date
      t.references :bankserv_bank_account
      t.references :bankserv_request
      t.integer :batch_id
      t.string :status, :default => "new"
      t.text :response
      t.string :user_ref
      t.string :internal_user_ref
      t.timestamps
    end
    
    create_table :bankserv_documents do |t|
      t.string :type
      t.references :set
      t.boolean :processed, :default => false
      t.string :transmission_status
      t.string :rec_status
      t.string :transmission_number
      t.string :reply_status
      t.text :error
      t.timestamps
    end
    
    create_table :bankserv_sets do |t|
      t.references :set
      t.string :type
      t.string :generation_number
      t.string :reply_status
      t.timestamps
    end
    
    create_table :bankserv_records do |t|
      t.references :set
      t.string :record_type
      t.string :reference
      t.text :data
      t.timestamps
    end
    
    create_table :bankserv_engine_configurations do |t|
      t.integer :interval_in_minutes
      t.string :input_directory
      t.string :output_directory
      t.string :archive_directory
    end
    
    create_table :bankserv_engine_processes do |t|
      t.boolean :running
      t.boolean :success
      t.text :response
      t.timestamps
      
      t.datetime :completed_at
    end
    
    # default values
    Bankserv::EngineConfiguration.create!(interval_in_minutes: 60, input_directory: "/tmp", output_directory: "/tmp", archive_directory: "/tmp")
    
  end

end