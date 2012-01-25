class Bankserv::ReplyDocument < Bankserv::Document
  
  def self.document_type
    'reply'
  end
  
  def self.store(string)
    options = Absa::H2h::Transmission::Document.hash_from_s(string, 'output')
    
    raise "WTH" unless options[:type] == "document"
    
    document = Bankserv::ReplyDocument.new(type: 'output')
    document.set = Bankserv::Set.from_hash(options)
    document.set.document = document # whaaaaaa?
    document.save!
    document
  end
  
  def self.process(document)
    raise "Expected reply document" unless document.output?
    raise "Document already processed" if document.processed?
    
    document.set.process
    document.processed = true
    document.save
  end
  
end