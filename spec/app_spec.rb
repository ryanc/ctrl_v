require 'spec_helper'

describe 'The ctrl-v Application' do
  include Rack::Test::Methods

  def app
    App
  end

  context 'when not signed in' do
    it 'redirects to new' do
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.location).to include('/new')
    end

    it 'new paste form' do
      get '/new'
      expect(last_response).to be_ok
      expect(last_response.body).to include('form')
    end

    it 'post new paste' do
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      expect(last_response.status).to eq(302)
      expect(last_response.location).not_to be_nil
      expect(last_response.location).to match(/\/p\/[a-zA-Z0-9]+$/)
    end

    it 'post validation failure' do
      post '/new', { _hp: "", paste: { content: nil } }
      expect(last_response.location).to be_nil
    end

    it 'honeypot failure' do
      post '/new', { _hp: "fail", paste: { content: "This is a test." } }
      expect(last_response.status).to eq(201)
      expect(last_response.location).to be_nil
    end

    it 'paste not found' do
      get '/p/1'
      expect(last_response.status).to eq(404)
    end

    it 'view paste html' do
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('This is a test')
    end

    it 'view paste text' do
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      paste_url = last_response.location.match(/\/p\/[a-zA-Z0-9]+$/).to_s
      get "#{paste_url}/text"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('This is a test')
      expect(last_response.headers['Content-Type']).to include('text/plain')
    end

    it 'download paste' do
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      paste_url = last_response.location.match(/\/p\/[a-zA-Z0-9]+$/).to_s
      get "#{paste_url}/download"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('This is a test')
      expect(last_response.headers['Content-Type']).to include('application/octet-stream')
      expect(last_response.headers['Content-Disposition']).to include('attachment; filename=')
      expect(last_response.headers['Content-Transfer-Encoding']).to include('binary')
    end

    it 'clone paste' do
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      paste_url = last_response.location.match(/\/p\/[a-zA-Z0-9]+$/).to_s
      get "#{paste_url}/clone"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/<textarea.+>This is a test\.<\/textarea>/m)
    end

    it 'latest paste' do
      get '/latest'
      expect(last_response.location).to include('/new')
      post '/new', { _hp: "", paste: { content: "This is a test." } }
      paste_url = last_response.location.match(/\/p\/[a-zA-Z0-9]+$/).to_s
      get '/latest'
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('This is a test')
    end
  end

  context 'when signed in' do
    let(:user) do
      User.create(
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
      )
    end

    before do
      # Simulate an authenticated session.
      get '/', {}, { 'rack.session' => { user_id: user.id }}
    end
  end
end
