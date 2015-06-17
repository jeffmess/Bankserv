require 'spec_helper'

describe Date do
  
  context "Checking dates against South African holidays/work days" do
    
    it "should know that Sunday is not a business day" do
      t = Time.local(2012, 1, 22, 10, 5, 0)
      Timecop.travel(t)      
      Date.today.business_day?.should be_falsey
    end
    
    it "should know that Saturday is not a business day" do
      t = Time.local(2012, 1, 21, 10, 5, 0)
      Timecop.travel(t)      
      Date.today.business_day?.should be_falsey
    end
    
    it "should know that holidays are not business days" do
      [ Time.local(2007,1,1), 
        Time.local(2007,3,21),
        Time.local(2007,4,6),
        Time.local(2007,4,9),
        Time.local(2007,4,27),
        Time.local(2007,5,1), 
        Time.local(2007,6,16),
        Time.local(2007,8,9),  
        Time.local(2007,9,24),
        Time.local(2007,12,16), 
        Time.local(2007,12,25),
        Time.local(2007,12,26)].each do |t|
        Timecop.travel(t)
        Date.today.business_day?.should be_falsey
      end
    end
    
    it "should know that Monday 23rd January 2012 is a business day" do
      t = Time.local(2012, 1, 23, 10, 5, 0)
      Timecop.travel(t)
      Date.today.business_day?.should be_truthy
    end
  end
end
