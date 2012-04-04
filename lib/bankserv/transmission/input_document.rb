class Bankserv::InputDocument < Bankserv::Document
  
  def self.document_type
    'input'
  end
  
  def self.store(string)
    options = ::Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
    
    raise "Expected a document set" unless options[:type] == "document"
    
    document = new(type: 'input', transmission_number: options[:data][0][:data][:transmission_no], transmission_status: options[:data][0][:data][:rec_status])
    document.set = Bankserv::Set.from_hash(options)
    document.set.document = document # whaaaaaa?
    document.save!
    document      
  end
  
  def self.fetch_next_transmission_number
    transmission_status = Bankserv::Configuration.live_env? ? "L" : "T"
    where(type: 'input', reply_status: 'ACCEPTED', transmission_status: transmission_status).maximum(:transmission_number)
  end
  
  def self.sets_with_work
    defined_input_sets.select(&:has_work?)
  end
  
  def self.sets_with_test_work
    defined_input_sets.select(&:has_test_work?)
  end
  
  def self.has_work?
    sets_with_work.any?
  end
  
  def self.has_test_work?
    sets_with_test_work.any?
  end
  
  def self.generate_test!(options = {})
    build!(options.merge(rec_status: "T")) if has_test_work?
  end
  
  def self.generate!(options = {})
    build!(options.merge(rec_status: "L")) if has_work?
  end
  
  def self.build!(options = {}) # move to private      
    options[:transmission_no] ||= fetch_next_transmission_number
    
    transmission_status = Bankserv::Configuration.live_env? ? "L" : "T"
    
    document = new(transmission_status: transmission_status, rec_status: options[:rec_status], type: 'input', transmission_number: options[:transmission_no])
    document.set = Bankserv::Transmission::UserSet::Document.generate(options.merge(rec_status: document.rec_status))
    document.set.document = document # whaaaaaa?
    
    input_sets = if document.rec_status == "L"
      sets_with_work
    else
      sets_with_test_work
    end
    
    input_sets.each do |set| 
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
  
  def self.for_transmission_number(transmission_number)
    where(type: 'input', transmission_number: transmission_number).first
  end
  
end