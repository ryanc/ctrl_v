$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'

require "rake"
require "yaml"
require "sequel"

env = ENV['RACK_ENV'] || 'development'
DB = Sequel.connect(ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[env])

desc 'Generate the session secret.'
task :secret do
  puts `openssl rand 64`.unpack('H*')
end

namespace :db do
  Sequel.extension :migration

  desc 'Migrate the database (options: VERSION=x).'
  task :migrate do
    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    Sequel::Migrator.run DB, 'db/migrations', :target => version
  end

  namespace :migrate do
    desc 'Runs the "up" for a given migration VERSION.'
    task :up do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      rasie 'VERSION is required' unless version
      Sequel::Migrator.run DB, 'db/migrations', :target => version
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      rasie 'VERSION is required' unless version
      Sequel::Migrator.run DB, 'db/migrations', :target => version
    end
  end
end
