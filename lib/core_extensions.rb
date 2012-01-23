class Hash
  
  def symbolize_keys
    dup.symbolize_keys!
  end
  
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
  
  def only(keypers)
    dup.only!(keypers)
  end
  
  def only!(keypers)
    self.select! {|k,v| keypers.include?(k)}
    self
  end
  
  def filter_attributes(model)
    self.only(model.send(:attribute_names).map(&:to_sym))
  end
  
end

class Date
  
  def business_day?
    return false if self.holiday?(:za)
    return false if self.saturday? || self.sunday?
    return true
  end
  
end
