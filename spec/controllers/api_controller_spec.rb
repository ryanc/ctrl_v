require 'spec_helper'

describe 'The ctrl-v Api' do
  include Rack::Test::Methods

  def app
    Api
  end

  context 'when not authenticated' do
    it 'should return unauthorized' do
      get '/paste/1'
      expect(last_response.status).to eq(401)

      post '/paste/1'
      expect(last_response.status).to eq(401)

      delete '/paste/1'
      expect(last_response.status).to eq(401)
    end

    it 'should reject invalid credentials' do
      authorize 'wrong', 'credentials'
      get '/paste/1'
      expect(last_response.status).to eq(401)
    end
  end

  context 'when authenticated' do
    let(:user) do
      User.create(
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
      )
    end

    it 'should create a paste' do
      authorize user.username, user.password
      post '/paste', { content: "This is a test." }
      expect(last_response.status).to eq(302)
      expect(last_response.location).to match(PASTE_URL_REGEX)
    end

    it 'should create a paste' do
      authorize user.username, user.password
      post '/paste', { content: "This is a test." }
      expect(last_response.status).to eq(302)
      expect(last_response.location).to match(PASTE_URL_REGEX)
      pid = last_response.location.match(/\/p\/([a-zA-Z0-9]+)/).captures[0]
      get "/paste/#{pid}"
      expect(last_response.status).to eq(200)
    end

    it 'should delete a paste' do
      authorize user.username, user.password
      post '/paste', { content: "This is a test." }
      expect(last_response.status).to eq(302)
      expect(last_response.location).to match(PASTE_URL_REGEX)
      pid = last_response.location.match(/\/p\/([a-zA-Z0-9]+)/).captures[0]
      delete "/paste/#{pid}"
      expect(last_response.status).to eq(204)
      get "/paste/#{pid}"
      expect(last_response.status).to eq(404)
    end

    it 'should not delete a paste that is owned by another user' do
      paste = Paste.create(
        content: "This is a test.",
        ip_addr: '127.0.0.1',
        one_time: true,
      )
      authorize user.username, user.password
      delete "/paste/#{paste.id_b62}"
      expect(last_response.status).to eq(403)
    end

    it 'should not allow an invalid paste' do
      authorize user.username, user.password
      post '/paste', { content: "" }
      expect(last_response.status).to eq(400)
    end
  end
end
