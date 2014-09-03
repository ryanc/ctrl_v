require 'spec_helper'

describe 'The ctrl-v Application' do
  include Rack::Test::Methods

  def app
    App
  end

  context 'when not registered' do
    it 'should render the login page' do
      get '/login'
      expect(last_response.body).to include('<form action="/login"')
    end

    it 'should render the login page' do
      get '/register'
      expect(last_response.body).to include('<form action="/register"')
    end

    it 'should render the password reset page' do
      get '/user/forgot_password'
      expect(last_response.body).to include('<form action="/user/forgot_password"')
    end

    it 'should register new accounts' do
      params = {
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
      }
      expect(User.find(username: 'test')).to be_nil
      post '/register', user: params
      expect(User.find(username: 'test')).not_to be_nil
    end

    it 'should not register a new account if invalid' do
      params = {
        name: nil,
        username: nil,
        email: nil,
        password: nil,
        password_confirmation: nil,
      }
      post '/register', user: params
      expect(User.find(username: 'test')).to be_nil
      expect(User.first).to be_nil
    end
  end

  context 'when registered and account is inactive' do
    before do
      # Simulate an authenticated session.
      #get '/', {}, { 'rack.session' => { user_id: user.id }}
      @user = User.create(
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
      )
    end
  
    it 'should not login with an inactive account' do
      post '/login', { username: 'test', password: 'password' }
      expect(last_request.env['rack.session']).not_to include('user_id')
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/login')
      follow_redirect!
      expect(last_response.body).to include('The username or password is incorrect.')
    end

    it 'should not activate an account if token is invalid' do
      user = User.find(username: 'test')
      expect(user).not_to be_active
      get '/user/activate', token: '0123456789'
      user.refresh
      expect(user).not_to be_active
      expect(user.activation_token).not_to be_nil
    end

    it 'should activate an account if token is valid' do
      user = User.find(username: 'test')
      expect(user).not_to be_active
      get '/user/activate', token: @user.activation_token
      user.refresh
      expect(user).to be_active
      expect(user.activation_token).to be_nil
    end
  end

  context 'when registered and account is active' do
    before do
      # Simulate an authenticated session.
      #get '/', {}, { 'rack.session' => { user_id: user.id }}
      @user = User.create(
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
        active: true,
      )
    end

    it 'should login with a correct password' do
      post '/login', { username: 'test', password: 'password' }
      expect(last_request.env['rack.session']['user_id']).to eq(@user.id)
      expect(last_response.location).to include('/new')
    end

    it 'should not login with an incorrect password' do
      post '/login', { username: 'test', password: 'wrong_password' }
      expect(last_request.env['rack.session']).not_to include('user_id')
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/login')
      follow_redirect!
      expect(last_response.body).to include('The username or password is incorrect.')
    end
  end

  context 'when authenticated' do
    before do
      # Simulate an authenticated session.
      @user = User.create(
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
        active: true,
      )
      get '/', {}, { 'rack.session' => { user_id: @user.id }}
    end

    it 'should logout if authenticated' do
      expect(last_request.env['rack.session']['user_id']).to eq(@user.id)
      get '/logout'
      expect(last_request.env['rack.session']['user_id']).to be_nil
    end
  end
end
