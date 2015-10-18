require ::File.expand_path './../app', __FILE__
require ::File.expand_path './../api', __FILE__
require 'sass/plugin/rack'

use Sass::Plugin::Rack
use Rack::Runtime

Sass::Plugin.options.merge!(:cache_location => './tmp/sass-cache')

map '/' do
  run App
end

map '/api' do
  run Api
end
