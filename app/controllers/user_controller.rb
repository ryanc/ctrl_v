require 'sinatra/flash'
require 'dotenv'

Dotenv.load

require_relative '../models/user.rb'

# Handle all user related requests.
class App < Sinatra::Base
  helpers do
    def authenticated?; session[:uid]; end
    def protected!; redirect to '/login' unless authenticated?; end
  end

  def registered?(username)
    Models::User.where(:username => username).empty? == false
  end

  get '/login' do
    mustache :login
  end

  post '/login' do
    user = Models::User.where(:username => params[:username]).first
    if user
      if user.authenticate(params[:password])
        session[:uid] = user.id
        redirect to '/pastes'
      end
    end
    flash[:error] = "The username or password is incorrect."
    mustache :login
  end

  get '/logout' do
    flash[:success] = "You have been logged out."
    session[:uid] = nil
    redirect to '/login' 
  end

  get '/register' do
    mustache :register
  end

  post '/register' do
    if registered? params[:username]
      flash[:error] = "The username '#{params[:username]}' is already taken."
      redirect to '/register'
    end
    # Create the user
    user = Models::User.new(
      :name => params[:name],
      :username => params[:username],
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation],
    )
    user.save
    flash[:success] = "You have succesfully registered."
    redirect to '/login'
  end
end
