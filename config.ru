require ::File.expand_path './../app', __FILE__
require ::File.expand_path './../api', __FILE__

map '/' do
  run App
end

map '/api' do
  run Api
end
