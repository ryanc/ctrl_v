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
    halt 201 unless params[:_hp].empty?
    paste = Models::Paste.create(
      :filename => params[:filename],
      :highlight => !params[:highlight].nil?,
      :content => params[:content],
      :user_id => @uid,
    )
    redirect to "/p/#{paste.id}"
  end

  get '/p/:id' do
    @paste = Models::Paste.find(:id => params[:id], :is_active => true)
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
      @paste.is_active = false
      @paste.save
      flash[:success] = "Paste ##{@paste.id} has been deleted."
      redirect to '/new'
    elsif params.has_key? 'clone'
      mustache :new
    else
      mustache :paste
    end
  end

  get '/latest' do
    id = Models::Paste.where(:is_active => true).order(:id).reverse.get(:id)
    if id.nil?
      redirect to '/new'
    else
      redirect to "/p/#{id}"
    end
  end
end
