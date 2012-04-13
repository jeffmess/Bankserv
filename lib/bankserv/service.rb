module Bankserv
  
  class Service < ActiveRecord::Base
    
    has_many :requests
    self.inheritance_column = :_type_disabled
    serialize :config
    
    def self.register(params)
      s = new
      s.active = true
      s.type = params.delete(:service_type) # 'ahv', 'debit', 'credit'
      s.client_code = params.delete(:client_code)
      s.config = params
      s.save!
      s.id
    end
    
    def self.active
      where(active: true)
    end
    
    # def self.request(options = {})
    #   options.merge!(type: self.type)
    #   create_request!(options)
    #   #Request.create!(options)
    # end
    # 
    # def self.active
    #   self.where(active: true).last
    # end
    # 
    # def self.client_code
    #   self.active.client_code
    # end
    # 
    # def self.client_name
    #   self.active.client_name
    # end
    # 
    # def self.client_abbreviated_name
    #   self.active.client_abbreviated_name
    # end
    # 
    # def self.user_code
    #   self.active.user_code
    # end
    # 
    # def self.department_code
    #   self.active.department_code
    # end
    # 
    # def self.user_generation_number
    #   self.active.user_generation_number
    # end
    # 
    # def self.internal_branch_code
    #   self.active.internal_branch_code
    # end
    # 
    # def self.transmission_number
    #   self.active.transmission_number
    # end
    # 
    # def self.set_transmission_number!(number)
    #   self.active.update_attributes!(transmission_number: number)
    # end
    # 
    # def self.reserve_transmission_number!
    #   reserved = self.transmission_number
    #   self.set_transmission_number!(reserved + 1)
    #   reserved
    # end
    # 
    def set_generation_number!(number)
      self.config[:generation_number] = number
      save!
    end
    
    def reserve_generation_number!
      reserved = config[:generation_number] || 1
      set_generation_number!(reserved + 1)
      reserved
    end
    # 
    # def self.live_env?
    #   self.active.live_env
    # end
    
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
  
  end
  
end