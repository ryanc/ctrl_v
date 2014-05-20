require 'rack-flash'

require 'app/models/paste'
require 'app/models/paste_content'

# Paste controller
class App < Sinatra::Base
  get '/' do
    redirect to '/new'
  end

  get '/new' do
    @paste = Models::Paste.new
    erb :new
  end

  post '/new' do
    # Honeypot test.
    halt 201 unless params[:_hp].empty?
    paste = Models::Paste.new
    paste.set_fields(params[:paste], paste_params)
    paste.user = current_user
    paste.ip_addr = request.ip
    paste.save
    redirect to "/p/#{paste.id_b62}"
  end

  get '/p/:id' do
    cache_control s_max_age: 86400
    @paste = Models::Paste.find(id_b62: params[:id], active: true, spam: false)
    halt(404) if @paste.nil?
    if params.key? 'raw'
      content_type 'text/plain'
      @paste.content.to_s
    elsif params.key? 'download'
      headers['Content-Type'] = 'application/octet-stream'
      headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
      headers['Content-Transfer-Encoding'] = 'binary'
      @paste.content.to_s
    elsif params.key? 'delete'
      halt(403) unless @paste.owner?(current_user)
      @paste.active = false
      @paste.save
      flash[:success] = "Paste ##{@paste.id_b62} has been deleted."
      redirect to '/new'
    elsif params.key? 'clone'
      erb :new
    else
      erb :paste
    end
  end

  get '/latest' do
    id = Models::Paste.where(active: true).order(:id).reverse.get(:id_b62)
    if id.nil?
      redirect to '/new'
    else
      redirect to "/p/#{id}"
    end
  end

  private

  def paste_params
    [:filename, :highlighted, :content]
  end
end
