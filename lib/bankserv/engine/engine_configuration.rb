class Bankserv::EngineConfiguration < ActiveRecord::Base
  
  def self.to_hash
    {
      interval_in_minutes: last.interval_in_minutes,
      input_directory: last.input_directory,
      output_directory: last.output_directory
    }
  end
  
end