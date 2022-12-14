require 'rack-flash'
require 'pony'

require 'app/models/user'

# Handle all user related requests.
class App < Sinatra::Base
  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.where(username: params[:username], active: true).first
    if user && user.authenticate(params[:password])
      login!(user)
      redirect '/new'
    else
      flash[:error] = 'The username or password is incorrect.'
      redirect '/login'
    end
  end

  get '/logout' do
    flash[:success] = 'You have been logged out.'
    logout!
    redirect to '/login'
  end

  get '/register' do
    @user = User.new
    erb :register
  end

  post '/register' do
    # Create the user
    @user = User.new
    @user.set_fields(params[:user], user_params)
    if @user.valid?
      @ip_addr = request.ip
      flash[:success] = 'An email has been sent containing instructions to activate your account.'
      @user.save
      activation_email(@user)
      redirect to '/login'
    else
      erb :register
    end
  end

  get '/user/activate' do
    user = User.where(activation_token: params[:token]).first
    if user
      user.activation_token = nil
      user.active = true
      user.save
      flash[:success] = 'Account activation complete.'
      redirect to '/login'
    else
      flash[:error] = 'Invalid activation token.'
      redirect to '/register'
    end
  end

  get '/user/forgot_password' do
    erb :forgot_password
  end

  post '/user/forgot_password' do
    @ip_addr = request.ip
    email = params[:email]
    @user = User.find(email: email)
    if @user
      @user.generate_password_reset_token if @user.password_reset_token.nil?
      password_reset_email(@user)
      @user.save
    end
    flash[:success] = 'An email has been sent containing instructions on how to reset your password.'
    redirect to '/login'
  end

  get '/user/validate_password_reset' do
    # missing reset token
    token = params[:token]
    redirect to '/login' unless token and !token.blank?
    user = User.find(password_reset_token: token)
    unless user && !user.password_reset_token_expired?
      flash[:error] = 'Password reset token is invalid.'
      redirect to '/login'
    end
    user.clear_password_reset_token
    user.save
    session[:reset] = true
    session[:reset_uid] = user.id
    redirect to '/user/reset_password'
  end

  get '/user/reset_password' do
    redirect to '/login' unless session[:reset]
    @user = User.find(id: session[:reset_uid])
    erb :reset_password
  end

  post '/user/reset_password' do
    redirect to '/login' unless session[:reset]
    user = User.find(id: session[:reset_uid])
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.save
    flash[:success] = 'A new password has been set.'
    # destroy the reset session
    session.delete :reset
    redirect to '/login'
  end

  private

  def user_params
    [:name, :username, :email, :password, :password_confirmation]
  end

  def activation_url(user)
    "#{base_url}/user/activate?token=#{user.activation_token}"
  end

  def password_reset_url(user)
    "#{base_url}/user/validate_password_reset?token=#{user.password_reset_token}"
  end

  def login!(user)
    session[:user_id] = user.id
    user.last_seen_at = Time.now
    user.save
  end

  def logout!
    session[:user_id] = nil if session[:user_id]
  end

  def activation_email(user)
    Pony.mail(
      to: user.email,
      from: 'no-reply@ctrl-v.io',
      subject: 'CTRL-V Registration',
      body: erb(:'email/activation', layout: false),
      via: settings.pony[:transport],
      via_options: settings.pony[:smtp]
    )
  end

  def password_reset_email(user)
    Pony.mail(
      to: user.email,
      from: 'no-reply@ctrl-v.io',
      subject: 'CTRL-V Reset Password',
      body: erb(:'email/forgot_password', layout: false),
      via: settings.pony[:transport],
      via_options: settings.pony[:smtp]
    )
  end
end
