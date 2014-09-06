require 'rack-flash'

require 'app/models/paste'

# Paste controller
class App < Sinatra::Base
  HISTORY_COUNT = 10

  get '/' do
    redirect to '/new'
  end

  get '/new' do
    @paste = Paste.new
    erb :new
  end

  post '/new' do
    # Honeypot test.
    halt 201 unless params[:_hp].empty?
    @paste = Paste.new
    @paste.set_fields(params[:paste], paste_params)
    @paste.user = current_user
    @paste.ip_addr = request.ip
    if @paste.valid?
      @paste.save
      redirect paste_url(@paste.id_b62)
    else
      erb :new
    end
  end

  get '/p/:id' do
    cache_control s_max_age: 86_400
    @paste = Paste.first(id_b62: params[:id])
    not_found if @paste.nil? || @paste.expired?
    @paste.increment_view_count
    erb :paste
  end

  get '/p/:id/text' do
    cache_control s_max_age: 86_400
    @paste = Paste.first(id_b62: params[:id])
    not_found if @paste.nil? || @paste.expired?
    content_type 'text/plain'
    @paste.increment_view_count
    @paste.content
  end

  get '/p/:id/download' do
    cache_control s_max_age: 86_400
    @paste = Paste.first(id_b62: params[:id])
    not_found if @paste.nil? || @paste.expired?
    headers['Content-Type'] = 'application/octet-stream'
    headers['Content-Disposition'] = "attachment; filename=#{@paste.filename}"
    headers['Content-Transfer-Encoding'] = 'binary'
    @paste.increment_view_count
    @paste.content
  end

  get '/p/:id/clone' do
    @paste = Paste.first(id_b62: params[:id])
    not_found if @paste.nil? || @paste.expired?
    erb :new
  end

  get '/p/:id/delete' do
    @paste = Paste.first(id_b62: params[:id])
    not_found if @paste.nil? || @paste.expired?
    halt(403) unless @paste.owner?(current_user)
    @paste.destroy
    flash[:success] = "Paste ##{@paste.id_b62} has been deleted."
    redirect to '/new'
  end

  get '/latest' do
    paste = Paste.not_expired.recent.first
    if paste.nil?
      redirect to '/new'
    else
      redirect paste_url(paste.id_b62)
    end
  end

  get '/mine' do
    redirect '/login' unless logged_in?
    @pastes = current_user.pastes_dataset.not_expired.recent.limit(HISTORY_COUNT)
    erb :mine
  end

  private

  def paste_params
    [:filename, :highlighted, :content, :expires]
  end
end
