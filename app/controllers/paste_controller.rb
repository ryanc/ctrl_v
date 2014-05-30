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
    cache_control s_max_age: 86_400
    @paste = paste(params[:id])
    halt(404) if @paste.nil?
    erb :paste
  end

  get '/p/:id/text' do
    cache_control s_max_age: 86_400
    @paste = paste(params[:id])
    halt(404) if @paste.nil?
    content_type 'text/plain'
    @paste.content.to_s
  end

  get '/p/:id/download' do
    cache_control s_max_age: 86_400
    @paste = paste(params[:id])
    halt(404) if @paste.nil?
    headers['Content-Type'] = 'application/octet-stream'
    headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
    headers['Content-Transfer-Encoding'] = 'binary'
    @paste.content.to_s
  end

  get '/p/:id/clone' do
    @paste = paste(params[:id])
    halt(404) if @paste.nil?
    erb :new
  end

  get '/p/:id/delete' do
    @paste = paste(params[:id])
    halt(404) if @paste.nil?
    halt(403) unless @paste.owner?(current_user)
    @paste.active = false
    @paste.save
    flash[:success] = "Paste ##{@paste.id_b62} has been deleted."
    redirect to '/new'
  end

  get '/latest' do
    id = Models::Paste.where(active: true).order(:id).reverse.get(:id_b62)
    if id.nil?
      redirect to '/new'
    else
      redirect to "/p/#{id}"
    end
  end

  get '/mine' do
    halt(403) unless logged_in?
    @pastes = Models::Paste.where(user: current_user, active: true)
                           .order(:created_at).reverse
                           .limit(10)
    erb :mine
  end

  private

  def paste(id)
    Models::Paste.find(id_b62: params[:id], active: true, spam: false)
  end

  def paste_params
    [:filename, :highlighted, :content]
  end
end
