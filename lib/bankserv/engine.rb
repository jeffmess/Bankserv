module Bankserv
  class Engine
    
    attr_accessor :process
    
    def initialize
      
    end
    
    def process!
      self.start!
      # check for reply files
      # check for output files
      # check for work
      self.finish!
    end
    
    def start!
      @process = EngineProcess.create!(running: true)
    end
    
    def process_reply_files
      
    end
    
    def finish!
      @process.update_attributes!(running: false, completed_at: Time.now, success: true, response: "Success")
    end
    
    def running?
      @process.running?
    end
    
    def self.start
      return true if self.running?

      if Date.today.business_day?
        queue = Bankserv::Engine.new
        queue.process!
      end
    end
    
    def self.running?
      EngineProcess.where(running: true).count > 0 
    end
    
    def self.config
      EngineConfiguration.to_hash
    end
    
    def self.interval=(interval)
      EngineConfiguration.last.update_attributes!(interval_in_minutes: interval)
    end
    
    def self.input_directory=(dir)
      EngineConfiguration.last.update_attributes!(input_directory: dir)
    end
    
    def self.output_directory=(dir)
      EngineConfiguration.last.update_attributes!(output_directory: dir)
    end
    
    def self.reply_files
      Dir.entries(Engine.config[:output_directory]).select {|file| file.upcase.starts_with? "REPLY" }
    end
    
    def self.output_files
      Dir.entries(Engine.config[:output_directory]).select {|file| file.upcase.starts_with? "OUTPUT" }
    end
    
  end
end