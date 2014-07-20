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
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt(404) if @paste.nil?
    erb :paste
  end

  get '/p/:id/text' do
    cache_control s_max_age: 86_400
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt(404) if @paste.nil?
    content_type 'text/plain'
    @paste.content.to_s
  end

  get '/p/:id/download' do
    cache_control s_max_age: 86_400
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt(404) if @paste.nil?
    headers['Content-Type'] = 'application/octet-stream'
    headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
    headers['Content-Transfer-Encoding'] = 'binary'
    @paste.content.to_s
  end

  get '/p/:id/clone' do
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt(404) if @paste.nil?
    erb :new
  end

  get '/p/:id/delete' do
    @paste = Models::Paste.active.first(id_b62: params[:id])
    halt(404) if @paste.nil?
    halt(403) unless @paste.owner?(current_user)
    @paste.active = false
    @paste.save
    flash[:success] = "Paste ##{@paste.id_b62} has been deleted."
    redirect to '/new'
  end

  get '/latest' do
    paste = Models::Paste.recent.active.first
    if paste.id.nil?
      redirect to '/new'
    else
      redirect to "/p/#{paste.id}"
    end
  end

  get '/mine' do
    redirect '/login' unless logged_in?
    @pastes = Models::Paste.where(user: current_user, active: true)
                           .order(:created_at).reverse
                           .limit(10)
    erb :mine
  end

  private

  def paste_params
    [:filename, :highlighted, :content]
  end
end
