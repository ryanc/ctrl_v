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
end
