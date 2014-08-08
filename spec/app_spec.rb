require 'spec_helper'

describe 'The ctrl-v Application' do
  include Rack::Test::Methods

  def app
    App
  end

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
  end
end
