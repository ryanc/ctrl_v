require 'rack-flash'
require 'pony'

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
    user = Models::User.where(:username => params[:username], :active => true).first
    if user
      if user.authenticate(params[:password])
        session[:uid] = user.id
        Models::User.where(:id => user.id).update(:last_seen_at => Time.now)
        redirect to '/new'
      end
    end
    flash[:error] = "The username or password is incorrect."
    redirect to '/login'
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
    # Create the user
    @user = Models::User.new(
      :name => params[:name],
      :username => params[:username],
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation],
    )
    unless @user.valid?
      @errors = @user.errors
      mustache :register
    else
      @user.save
      @ip_addr = request.ip
      @request = request
      Pony.mail(
        :to => @user.email,
        :from => 'no-reply@ctrl-v.io',
        :subject => 'CTRL-V Registration',
        :body => mustache(:email, :layout => false),
        :via => settings.pony[:transport],
        :via_options => settings.pony[:smtp],
      )
      flash[:success] = "An email has been sent containing instructions to activate your account."
      redirect to '/login'
    end
  end

  get '/user/activate' do
    user = Models::User.where(:activation_token => params[:token]).first
    if user
      user.activation_token = nil
      user.active = true
      user.save
      flash[:success] = "Account activation complete."
      redirect to '/login'
    else
      flash[:error] = "Invalid activation token."
      redirect to '/register'
    end
  end

  get '/reset_password' do
    protected!
    uid = session[:uid]
    user = Models::User.find(:id => uid)
    user.generate_password_reset_token if user
    user.save
    nil
  end
end
