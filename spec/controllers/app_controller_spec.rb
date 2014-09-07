require 'spec_helper'

describe 'The ctrl-v Application' do
  include Rack::Test::Methods

  def app
    App
  end

  it 'should return not found.' do
    get '/not_found'
    expect(last_response.status).to eq(404)
    expect(last_response.body).to include('Paste not found or no longer available.')
  end
end
