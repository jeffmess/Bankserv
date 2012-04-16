class Bankserv::OutputDocument < Bankserv::Document
  
  def self.document_type
    'output'
  end
  
  def self.store(string)
    options = Absa::H2h::Transmission::Document.hash_from_s(string, 'output')
    
    raise "Expected a document set" unless options[:type] == "document"
    
    document = Bankserv::OutputDocument.new(
      type: 'output',
      client_code: options[:data][0][:data][:client_code]
    )
    
    document.set = Bankserv::Set.from_hash(options)
    document.set.document = document # whaaaaaa?
    document.save!
    document
  end
  
  def process!
    raise "Document already processed" if processed?
    
    self.set.process
    self.processed = true
    self.save
  end
  
end