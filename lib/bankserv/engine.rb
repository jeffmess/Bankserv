module Bankserv
  class Engine
    
    attr_accessor :process, :logs, :success, :service
    
    def initialize(service)
      @service = service
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
      self.process_input_files
      self.finish!
      # self.perform_post_checks!
    end
    
    def start!
      @process = EngineProcess.create!(running: true)
    end
        
    def process_reply_files
      begin
        Engine.reply_files(@service).each do |file|
          @logs[:reply_files] << "Processing #{file}."
          
          # contents = File.open("#{Bankserv::Engine.output_directory}/#{file}", "rb").read
          contents = File.open("#{@service.config[:reply_directory]}/#{file}", "rb").read
          document = Bankserv::ReplyDocument.store(contents)
          document.process!
          
          @logs[:reply_files] << "Processing #{file}. Complete."
          
          self.archive_file!("#{@service.config[:incoming_directory]}/#{file}")
          @logs[:reply_files] << "#{file} Archived."
        end
      rescue Exception => e
        @logs[:reply_files] << "Error occured! #{e.message}"
        @success = false
      end
    end
    
    def process_output_files
      #     ------------------------------------------------------------------------------------------------------------
      #    | NB: ABSA place output files in our incoming directory! They take our input files from our outgoing folder.| 
      #    ------------------------------------------------------------------------------------------------------------
      begin
        Engine.output_files(@service).each do |file|
          @logs[:output_files] << "Processing #{file}."
          
          # contents = File.open("#{Bankserv::Engine.output_directory}/#{file}", "rb").read
          contents = File.open("#{@service.config[:incoming_directory]}/#{file}", "rb").read
          if @service.kind_of? StatementService
            document = Bankserv::Statement.store(contents)
          else
            document = Bankserv::OutputDocument.store(contents)
          end

          document.process!
          
          @logs[:output_files] << "Processing #{file}. Complete."
          
          self.archive_file!("#{@service.config[:incoming_directory]}/#{file}")
          @logs[:output_files] << "#{file} Archived."
        end
      rescue Exception => e
        @logs[:output_files] << "Error occured! #{e.message}"
        @success = false
      end
    end
    
    def process_input_files        
      # input_services.each do |bankserv_service|
      begin
        return if self.expecting_reply_file?(@service)
      
        if document = Bankserv::InputDocument.generate!(@service)
          @logs[:input_files] << "Input Document created with id: #{document.id}" if document
        
          if self.write_file!(document)
            document.mark_processed!
          end
        end
      rescue Exception => e
        @logs[:input_files] << "Error occured! #{e.message}"
        @success = false
      end
      # end
    end
    
    def input_services
      Bankserv::Service.active.select(&:can_transmit?)
    end
    
    def write_file!(document)
      begin
        transmission = Absa::H2h::Transmission::Document.build([document.to_hash])
        file_name = generate_input_file_name(document)
        
        File.open("#{@service.config[:outgoing_directory]}/#{file_name}", 'w') { |f|
          f.write transmission
        }
        @logs[:input_files] << "Input Document File created. File name: #{file_name}"
      rescue Exception => e
        @logs[:input_files] << "Error occured. #{e.message}"
        return false
      end
      
      true
    end
    
    def generate_input_file_name(document)
      "INPUT.#{document.id}.#{Time.now.strftime('%y%m%d%H%M%S')}.txt"
    end
    
    def archive_file!(file)
      year, month = Date.today.year, Date.today.month
      
      Dir::mkdir("#{@service.config[:archive_directory]}/#{year}") unless File.directory?("#{@service.config[:archive_directory]}/#{year}")
      Dir::mkdir("#{@service.config[:archive_directory]}/#{year}/#{month}") unless File.directory?("#{@service.config[:archive_directory]}/#{year}/#{month}")
      FileUtils.mv(file, "#{@service.config[:archive_directory]}/#{year}/#{month}/")
    end
    
    def expecting_reply_file?(bankserv_service)
      Bankserv::Document.where(type: 'input', reply_status: nil, processed: true, client_code: bankserv_service.client_code).count > 0
    end
    
    def finish!
      @process.update_attributes!(running: false, completed_at: Time.now, success: @success, response: @logs)
    end
    
    def running?
      @process.running?
    end
    
    def self.start
      return true if self.running?

      # if Date.today.business_day?
      Bankserv::Service.active.each do |service|
        queue = Bankserv::Engine.new(service)
        queue.process!
      end
      # end
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
    
    def self.archive_directory
      config[:archive_directory]
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
    
    def self.archive_directory=(dir)
      EngineConfiguration.last.update_attributes!(archive_directory: dir)
    end
    
    def self.reply_files(service)
      Dir.entries(service.config[:reply_directory]).select {|file| file.upcase.starts_with? "REPLY" }
    end
    
    def self.output_files(service)
      return Dir.entries(service.config[:incoming_directory]).select {|file| file.upcase.starts_with? "OUTPUT" } unless ((service.kind_of? StatementService) or (service.kind_of? NotifyMeStatementService))
      Dir.entries(service.config[:incoming_directory]).delete_if {|element| File.directory?(element)}
    end
    
  end
end