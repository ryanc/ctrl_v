$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'

# REST API
class Api < Sinatra::Base
  use Rack::Auth::Basic, 'API requires authentication' do |username, password|
    user = Models::User.find(username: username)
    user && user.authenticate(password)
  end

  get '/paste/:id' do
    content_type 'text/plain'
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt 404, 'Not Found' if paste.nil?
    paste.content.to_s
  end

  post '/paste' do
    username = request.env['REMOTE_USER']
    paste = Models::Paste.create(
      filename: params[:filename],
      highlighted: params[:highlighted] || true,
      content: params[:content],
      user_id: Models::User.find(username: username).id,
      ip_addr: request.ip
    )
    redirect to "/p/#{paste.id_b62}"
  end

  delete '/paste/:id' do
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt 404, 'Not Found' if paste.nil?
    paste.active = false
    paste.save
    204
  end
end
