module Bankserv
  class Engine
    
    attr_accessor :process
    
    def initialize
      
    end
    
    def process!
      self.start!
      self.process_reply_files
      # process output files
      # process input documents
      self.finish!
      self.perform_post_checks!
    end
    
    def start!
      @process = EngineProcess.create!(running: true)
    end
        
    def process_reply_files
      Engine.reply_files.each do |file|
        contents = File.open("#{Bankserv::Engine.output_directory}/#{file}", "rb").read
        document = Bankserv::OutputDocument.store(contents)
        Bankserv::ReplyDocument.process(document)
      end
    end
    
    def process_input_files
      unless self.expecting_reply_file?
        document = Bankserv::InputDocument.generate!(
          client_code: Bankserv::Configuration.client_code, 
          client_name: Bankserv::Configuration.client_name, 
          th_for_use_of_ld_user: ""
        )
      
        if self.write_file!(document)
          document.mark_processed!
        end
        # write to input directory
        # mark as processed
      
      end
    end
    
    def write_file!(document)
      begin
        transmission = Absa::H2h::Transmission::Document.build([document.to_hash])
        File.open("#{Bankserv::Engine.input_directory}/INPUT.#{Time.now.strftime('%y%m%d%H%M%S')}.txt", 'w') { |f|
          f.puts transmission
        }
        true
      rescue
        false
      end
    end
    
    def expecting_reply_file?
      Bankserv::Document.where(type: 'input', reply_status: nil, processed: true).count > 0
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
    
    def self.interval
      config[:interval]
    end
    
    def self.input_directory
      config[:input_directory]
    end
    
    def self.output_directory
      config[:output_directory]
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
      Dir.entries(output_directory).select {|file| file.upcase.starts_with? "REPLY" }
    end
    
    def self.output_files
      Dir.entries(output_directory).select {|file| file.upcase.starts_with? "OUTPUT" }
    end
    
  end
end