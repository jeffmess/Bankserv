class CreateBankservTables < ActiveRecord::Migration
  def self.change
    
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
      t.string :type
      t.integer :amount
      t.string :action_date
      t.references :bankserv_bank_account
      t.integer :set_id
      t.boolean :processed, :default => false
      t.string :status
      t.text :response
      t.string :user_ref
      t.timestamps
    end
    
    create_table :bankserv_credits do |t|
      t.string :type
      t.integer :amount
      t.string :action_date
      t.references :bankserv_bank_account
      t.integer :set_id
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
    end
    
    create_table :bankserv_sets do |t|
      t.references :document
      t.string :type
    end
    
    create_table :bankserv_records do |t|
      t.references :set
      t.string :type
      t.text :data
    end
    
  end

end