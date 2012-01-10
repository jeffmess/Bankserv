# require 'rubygems'
# require 'bundler/setup'
# 
# require 'bankserv'
# 
# RSpec.configure do |config|
#   # some (optional) config here
# end

require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize! :active_record

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions
