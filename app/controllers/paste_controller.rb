require 'sinatra/flash'
require 'dotenv'

require 'app/models/paste'
require 'app/models/paste_content'

Dotenv.load

class App < Sinatra::Base
  get '/new' do
    mustache :new
  end

  post '/new' do
    paste = Models::Paste.create(
      :filename => params[:filename],
      :highlight => !params[:highlight].nil?,
      :content => params[:content],
    )
    redirect to "/p/#{paste.id}"
  end

  get '/p/:id' do
    @paste = Models::Paste.find(:id => params[:id])
    halt(404) if @paste.nil?
    if params.has_key? 'raw'
      content_type 'text/plain'
      @paste.content.to_s
    elsif params.has_key? 'download'
      headers['Content-Type'] = 'application/octet-stream'
      headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
      headers['Content-Transfer-Encoding'] = 'binary'
      @paste.content.to_s
    else
      mustache :paste
    end
  end

  get '/latest' do
    id = Models::Paste.order(:id).reverse.get(:id)
    redirect to '/new' if id.nil?
    redirect to "/p/#{id}"
  end
end
