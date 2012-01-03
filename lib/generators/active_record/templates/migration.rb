class CreateBankservTables < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|      
      t.timestamps
    end
    
    create_table :task_lists do |t|
      t.timestamps
    end
  end

  def self.down
    
  end
end