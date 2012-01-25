module Bankserv
  class Engine
    
    attr_accessor :process, :logs, :success
    
    def initialize
      @logs = {
        reply_files: [],
        output_files: [],
        input_files: []
      }
      
      @success = true
    end
    
    def process!
      self.start!
      self.process_reply_files
      self.process_output_files
      self.process_input_documents      
      self.finish!
      # self.perform_post_checks!
    end
    
    def start!
      @process = EngineProcess.create!(running: true)
    end
        
    def process_reply_files
      begin
        Engine.reply_files.each do |file|
          @logs[:reply_files] << "Processing #{file}."
          
          contents = File.open("#{Bankserv::Engine.output_directory}/#{file}", "rb").read
          document = Bankserv::Document.store_output_document(contents)
          Bankserv::Document.process_output_document(document)
          
          @logs[:reply_files] << "Processing #{file}. Complete."
        end
      rescue Exception => e
        @logs[:reply_files] << "Error occured! #{e.message}"
        @success = false
      end
    end
    
    def process_output_files
      begin
        Engine.output_files.each do |file|
          @logs[:output_files] << "Processing #{file}."
          
          contents = File.open("#{Bankserv::Engine.output_directory}/#{file}", "rb").read
          document = Bankserv::Document.store_output_document(contents)
          Bankserv::Document.process_output_document(document)
          
          @logs[:output_files] << "Processing #{file}. Complete."
        end
      rescue Exception => e
        @logs[:output_files] << "Error occured! #{e.message}"
        @success = false
      end
    end
    
    def process_input_files
      unless self.expecting_reply_file?
        begin
          document = Bankserv::Document.generate!(
            client_code: Bankserv::Configuration.client_code, 
            client_name: Bankserv::Configuration.client_name, 
            th_for_use_of_ld_user: ""
          )
          @logs[:input_files] << "Input Document created with id: #{document.id}"
        rescue Exception => e
          @logs[:input_files] << "Error occured! #{e.message}"
          @success = false
        end
      
        if self.write_file!(document)
          document.mark_processed!
        end      
      end
    end
    
    def write_file!(document)
      begin
        transmission = Absa::H2h::Transmission::Document.build([document.to_hash])
        file_name = "INPUT.#{Time.now.strftime('%y%m%d%H%M%S')}.txt"
        File.open("#{Bankserv::Engine.input_directory}/#{file_name}", 'w') { |f|
          f.puts transmission
        }
        @logs[:input_files] << "Input Document File created. File name: #{file_name}"
        true
      rescue Exception => e
        @logs[:input_files] << "Error occured. #{e.message}"
        false
      end
    end
    
    def expecting_reply_file?
      Bankserv::Document.where(type: 'input', reply_status: nil, processed: true).count > 0
    end
    
    def finish!
      @process.update_attributes!(running: false, completed_at: Time.now, success: @success, response: @logs)
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