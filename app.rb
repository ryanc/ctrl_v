$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'
require 'sinatra/flash'
require 'mustache/sinatra'
require 'sequel'
require 'yaml'
require 'dotenv'

Dotenv.load

env = ENV['RACK_ENV'] || 'production'
DB = Sequel.connect(ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[env])

class App < Sinatra::Base
  enable :sessions
  register Mustache::Sinatra
  register Sinatra::Flash
  require 'app/views/layout'

  set :mustache, {
    :views => 'app/views',
    :templates => 'app/templates',
  }

  configure do
    set :session_secret, ENV['SECRET_TOKEN'].unpack('H*').first
  end

  before do
    @uid = session[:uid]
    @current_user = Models::User.find(:id => @uid)
    @flash_error = flash[:error]
    @flash_success = flash[:success]
  end
end

require_relative 'app/controllers/user_controller.rb'
require_relative 'app/controllers/paste_controller.rb'
