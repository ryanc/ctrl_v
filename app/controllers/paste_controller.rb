require 'sinatra/flash'

require 'app/models/paste'
require 'app/models/paste_content'

class App < Sinatra::Base
  get '/' do
    redirect to '/new'
  end

  get '/new' do
    mustache :new
  end

  post '/new' do
    # Honeypot test.
    halt 201 unless params[:_hp].empty?
    paste = Models::Paste.create(
      :filename => params[:filename],
      :highlighted => !params[:highlighted].nil?,
      :content => params[:content],
      :user_id => @uid,
      :ip_addr => request.ip,
    )
    redirect to "/p/#{paste.id_b62}"
  end

  get '/p/:id' do
    cache_control :max_age => 86400
    @paste = Models::Paste.find(:id_b62 => params[:id], :active => true, :spam => false)
    halt(404) if @paste.nil?
    if params.has_key? 'raw'
      content_type 'text/plain'
      @paste.content.to_s
    elsif params.has_key? 'download'
      headers['Content-Type'] = 'application/octet-stream'
      headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
      headers['Content-Transfer-Encoding'] = 'binary'
      @paste.content.to_s
    elsif params.has_key? 'delete'
      halt(403) unless @paste.user_id == @uid
      @paste.active = false
      @paste.save
      flash[:success] = "Paste ##{@paste.id_b62} has been deleted."
      redirect to '/new'
    elsif params.has_key? 'clone'
      mustache :new
    else
      mustache :paste
    end
  end

  get '/latest' do
    id = Models::Paste.where(:active => true).order(:id).reverse.get(:id_b62)
    if id.nil?
      redirect to '/new'
    else
      redirect to "/p/#{id}"
    end
  end
end
