require 'sinatra/flash'
require 'dotenv'

Dotenv.load

require_relative '../models/user.rb'

# Handle all user related requests.
class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  helpers do
    def authenticated?; session[:uid]; end
    def protected!; redirect to '/login' unless authenticated?; end
  end

  get '/login' do
    @flash = flash
    mustache :login
  end

  post '/login' do
    user = Models::User.where(:username => params[:username]).first
    if user
      if user.authenticate(params[:password])
        session[:uid] = user.id
        redirect to '/tasks'
      end
    end
    flash.now[:error] = "The username or password is incorrect."
    @flash = flash
    mustache :login
  end

  get '/logout' do
    flash[:success] = "You have been logged out."
    session[:uid] = nil
    redirect to '/login' 
  end
end
