class Bankserv::InputDocument < Bankserv::Document
  
  def self.document_type
    'input'
  end
  
  def self.store(string)
    options = Absa::H2h::Transmission::Document.hash_from_s(string, 'input')
    
    raise "Expected a document set" unless options[:type] == "document"
    
    document = new(
      type: 'input', 
      transmission_number: options[:data][0][:data][:transmission_no], 
      transmission_status: options[:data][0][:data][:rec_status],
      client_code: options[:data][0][:data][:client_code]
    )
    
    document.set = Bankserv::Set.from_hash(options)
    document.set.document = document # whaaaaaa?
    document.save!
    document      
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
  
  def self.generate!(bankserv_service)
    if bankserv_service.is_test_env?
      return unless has_test_work?
    else
      return unless has_work?
    end
    
    options = {}
    options.merge! rec_status: bankserv_service.config[:transmission_status]
    options.merge! client_code: bankserv_service.client_code
    options.merge! client_name: bankserv_service.config[:client_name]
    options.merge! th_for_use_of_ld_user: bankserv_service.config[:transmission_number]

    if bankserv_service.config.has_key? :internal
      # swap the internal status and check if the service has any work.
      bankserv_service.config[:internal] = !bankserv_service.config[:internal]
      bankserv_service.save
      return unless bankserv_service.has_work?
    end
    
    transmission_status = bankserv_service.config[:transmission_status]
    raise "Transmission status not specified" if transmission_status.nil?
    options[:transmission_no] ||= bankserv_service.config[:transmission_number]
    
    document = new(
      transmission_status: transmission_status, 
      rec_status: options[:rec_status], 
      type: 'input', 
      transmission_number: options[:transmission_no],
      client_code: bankserv_service.client_code
    )
    
    document.set = Bankserv::Transmission::UserSet::Document.generate(options.merge(rec_status: document.rec_status))
    document.set.document = document # whaaaaaa?
    
    input_sets = if document.rec_status == "L"
      sets_with_work
    else
      sets_with_test_work
    end
    
    input_sets.select!{|s| s.bankserv_service.client_code == bankserv_service.client_code}
    return unless input_sets.count > 0
    
    input_sets.each do |set|
      hash = {rec_status: document.rec_status}
      hash.merge!(internal: bankserv_service.config[:internal]) if bankserv_service.config.has_key?(:internal)

      document.set.sets << set.generate(hash)
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