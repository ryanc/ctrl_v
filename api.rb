$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'sinatra/base'

# REST API
class Api < Sinatra::Base
  use Rack::Auth::Basic, 'API requires authentication' do |username, password|
    user = User.find(username: username)
    user && user.authenticate(password)
  end

  get '/paste/:id' do
    content_type 'text/plain'
    @paste = Paste.first(id_b62: params[:id])
    halt 404, 'Not Found' if @paste.nil?
    @paste.increment_view_count
    @paste.content
  end

  post '/paste' do
    username = request.env['REMOTE_USER']
    paste = Paste.create(
      filename: params[:filename],
      highlighted: params[:highlighted] || true,
      content: params[:content],
      user_id: User.find(username: username).id,
      ip_addr: request.ip
    )
    redirect to "/p/#{paste.id_b62}"
  end

  delete '/paste/:id' do
    username = request.env['REMOTE_USER']
    @paste = Paste.first(id_b62: params[:id])
    halt 404, 'Not Found' if @paste.nil?
    halt 403 unless @paste.owner?(User.find(username: username))
    @paste.destroy
    204
  end
end
