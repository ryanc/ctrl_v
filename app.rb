$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'
require 'mustache/sinatra'
require 'sequel'
require 'yaml'
require 'dotenv'

Dotenv.load

env = ENV['RACK_ENV'] || 'production'
config = YAML.load_file('config/database.yml')[env]
DB = Sequel.connect(config)

class App < Sinatra::Base
  register Mustache::Sinatra
  require 'app/views/layout'

  set :mustache, {
    :views => 'app/views',
    :templates => 'app/templates',
  }

  configure do
    set :session_secret, File.read('session.key')
  end

  before do
    @uid = session[:uid]
  end
end

#require_relative 'app/controllers/user_controller.rb'
require_relative 'app/controllers/paste_controller.rb'