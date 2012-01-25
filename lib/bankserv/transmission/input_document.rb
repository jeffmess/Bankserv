class Bankserv::InputDocument < Bankserv::Document
  
  def self.document_type
    'input'
  end
  
  def self.store(string)
    options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
    
    raise "WTH" unless options[:type] == "document"
    
    document = Bankserv::Document.new(type: 'input', transmission_number: options[:data][0][:data][:transmission_no], transmission_status: options[:data][0][:data][:rec_status])
    document.set = Bankserv::Set.from_hash(options)
    document.set.document = document # whaaaaaa?
    document.save!
    document      
  end
  
  def self.fetch_next_transmission_number
    if Bankserv::Configuration.live_env?
      Bankserv::Document.where(type: 'input', reply_status: 'ACCEPTED', transmission_status: "L").maximum(:transmission_number)
    else
      Bankserv::Document.where(type: 'input', reply_status: 'ACCEPTED', transmission_status: "T").maximum(:transmission_number)
    end
  end
  
  def self.has_work?
    defined_input_sets.any? {|set| set.has_work? }
  end
  
  def self.has_test_work?
    defined_input_sets.any? {|set| set.has_test_work? }
  end
  
  def self.generate_test!(options = {})
    return unless self.has_test_work?
    self.build!(options.merge(rec_status: "T"))
  end
  
  def self.generate!(options = {})
    return unless self.has_work?
    self.build!(options.merge(rec_status: "L"))
  end
  
  def self.build!(options = {}) # move to private      
    options[:transmission_no] ||= self.fetch_next_transmission_number
    
    transmission_status = Bankserv::Configuration.live_env? ? "L" : "T"
    
    document = self.new(transmission_status: transmission_status, rec_status: options[:rec_status], type: 'input', transmission_number: options[:transmission_no])
    document.set = Bankserv::Transmission::UserSet::Document.generate(options.merge(rec_status: document.rec_status))
    document.set.document = document # whaaaaaa?
    
    sets_with_work = if document.rec_status == "L"
      self.defined_input_sets.select(&:has_work?)
    else
      self.defined_input_sets.select(&:has_test_work?)
    end
    
    sets_with_work.each do |set| 
      document.set.sets << set.generate(rec_status: document.rec_status)
      document.set.sets[-1].set = document.set # whaaaaaa?
    end
    
    document.save!
    document
  end
      
  def self.defined_input_sets
    [
      Bankserv::Transmission::UserSet::AccountHolderVerification, 
      Bankserv::Transmission::UserSet::Debit,
      Bankserv::Transmission::UserSet::Credit
    ]
  end
  
  
end