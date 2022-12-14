$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'
require 'rack-flash'
require 'sequel'
require 'yaml'
require 'sinatra/config_file'
require 'active_support/all'
require 'action_view'
require 'helpers'

env = ENV['RACK_ENV'] || 'production'
DB = Sequel.connect(ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[env])

# Main application
class App < Sinatra::Base

  # :nocov:
  configure :development do
    require 'better_errors'
    require 'logger'
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
    DB.loggers << Logger.new($stderr)
  end
  # :nocov:

  # enable sessions
  use Rack::Session::Cookie, secret: File.read('config/secret.key')

  # register plugins
  register Sinatra::ConfigFile
  use Rack::Flash

  # load the configuration file
  config_file 'config/settings.yml'

  helpers do
    def e(text)
      Rack::Utils.escape_html(text)
    end

    def paste_url(id)
      id.gsub!(/[^a-zA-Z0-9]/, '')
      "/p/#{id}"
    end

    include ActionView::Helpers::DateHelper
    include ViewHelpers
  end

  not_found do
    @error = 'Paste not found or no longer available.'
    erb :error
  end

  private

  def current_user
    @current_user ||= User[session[:user_id]]
  end

  def logged_in?
    current_user != nil
  end

  # :nocov:
  def base_url
    unless [443, 80].include? @request.port
      "#{@request.scheme}://#{@request.host}:#{@request.port}"
    else
      "#{@request.scheme}://#{@request.host}"
    end
  end
  # :nocov:
end

Dir['app/controllers/*_controller.rb'].each { |file| require file }
