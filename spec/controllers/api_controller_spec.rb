require 'spec_helper'

PASTE_URL_REGEX = /\/p\/[a-zA-Z0-9]+$/

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
  end
end
