module Bankserv
  
  class Service < ActiveRecord::Base
    
    has_many :requests
    serialize :config
    
    def self.register(params)
      s = new
      s.active = true
      s.client_code = params.delete(:client_code)
      s.config = params
      s.save!
      s
    end
    
    def self.active
      where(active: true)
    end
    
    def set_generation_number!(number)
      self.config[:generation_number] = number
      save!
    end
    
    def reserve_generation_number!
      reserved = config[:generation_number] || 1
      set_generation_number!(reserved + 1)
      reserved
    end
    
    def sequence_number
      sequence_number = config[:sequence_number] || 1
      sequence_number = 1 unless (config[:sequence_number_updated_at] || Time.now).to_date == Date.today
      sequence_number
    end
    
    def set_sequence_number!(number)
      self.config[:sequence_number] = number
      self.config[:sequence_number_updated_at] = Time.now
      save!
    end
    
    def reserve_sequence_number!(reserved = nil)
      reserved ||= sequence_number
      set_sequence_number!(reserved.to_i + 1)
      reserved
    end
    
    def is_test_env?
      config[:transmission_status] == "T"
    end
    
    def can_transmit?
      false
    end
  
  end
  
  class DebitService < Service
    def request(params)
      params.merge!(type: 'debit', service_id: id)
      params.merge!(test: true) if is_test_env?
      Request.create!(params)
    end
    
    def can_transmit?
      true
    end
  end
  
  class CreditService < Service
    def request(params)
      params.merge!(type: 'credit', service_id: id)
      params.merge!(test: true) if is_test_env?
      Request.create!(params)
    end
    
    def can_transmit?
      true
    end
  end
  
  class AHVService < Service
    def request(params)
      params.merge!(type: 'ahv', service_id: id)
      params.merge!(test: true) if is_test_env?
      Request.create!(params)
    end
    
    def can_transmit?
      true
    end  
  end
  
  class StatementService < Service
    def request(params)
      params.merge!(type: 'statement', service_id: id)
      params.merge!(test: true) if is_test_env?
      Request.create!(params)
    end
  end
  
  class NotifyMeStatementService < Service
    def request(params)
      params.merge!(type: 'notify_me', service_id: id)
      params.merge!(test: true) if is_test_env?
      Request.create!(params)
    end
  end
  
end