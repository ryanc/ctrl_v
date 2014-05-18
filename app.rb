$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'
require 'rack-flash'
require 'mustache/sinatra'
require 'sequel'
require 'yaml'
require 'sinatra/config_file'

env = ENV['RACK_ENV'] || 'production'
DB = Sequel.connect(ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[env])

class App < Sinatra::Base
  # enable sessions
  use Rack::Session::Cookie, :secret => File.read('config/secret.key')

  # register plugins
  register Mustache::Sinatra
  register Sinatra::ConfigFile
  use Rack::Flash

  # mustache layout
  require 'app/views/layout'

  # load the configuration file
  config_file 'config/settings.yml'

  set :mustache, {
    :views => 'app/views',
    :templates => 'app/templates',
  }

  before do
    @uid = session[:uid] if session and session.has_key?(:uid)
    @current_user = Models::User.find(:id => @uid)
    if session.exists? and flash
      @flash_error = flash[:error] if flash.has?(:error)
      @flash_success = flash[:success] if flash.has?(:success)
    end
  end

  helpers do
    def e(text)
      Rack::Utils.escape_html(text)
    end
  end

  private

  def current_user
    @current_user ||= Models::User[session[:uid]]
  end

  def use_cdn?
    true
  end

  def logged_in?
    current_user != nil
  end

  def base_url
    unless [443, 80].include? @request.port
      "#{@request.scheme}://#{@request.host}:#{@request.port}"
    else
      "#{@request.scheme}://#{@request.host}"
    end
  end
end

require_relative 'app/controllers/user_controller.rb'
require_relative 'app/controllers/paste_controller.rb'
