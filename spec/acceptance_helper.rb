$LOAD_PATH.unshift(File.expand_path('../', File.dirname(__FILE__)))

ENV['RACK_ENV'] = 'test'

require 'simplecov'
require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require 'app'
require 'api'

#PASTE_URL_REGEX = /\/p\/[a-zA-Z0-9]+$/

Capybara.app = App

# Global around filters should work
RSpec.configure do |c|
  c.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true){example.run}
  end
  c.include Capybara::DSL
end
