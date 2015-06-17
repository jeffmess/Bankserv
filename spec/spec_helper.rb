require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize! :active_record

require 'rspec/rails'

require './spec/support/helpers.rb'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.color = true
  config.formatter = :documentation # :progress, :html, :textmate
  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |c|
    c.syntax = :should
  end
  
  config.mock_with :rspec do |c|
    c.syntax = :should
  end
end

FactoryGirl.find_definitions
