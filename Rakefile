$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'

require "rake"
require "yaml"
require "sequel"

env = ENV['RACK_ENV'] || 'production'
DB = Sequel.connect(ENV['DATABASE_URL'] || YAML.load_file('config/database.yml')[env])

desc "Generate the session secret."
task :secret do
  puts `openssl rand 64`.unpack('H*')
end

namespace :db do
  desc "Perform migration up to latest migration available"
  task :migrate do
    Sequel::Migrator.run DB, 'db/migrations'
    puts "<= db:migrate executed"
  end
  namespace :migrate do
    Sequel.extension :migration

    desc "Perform automigration (reset your db data)"
    task :auto do
      Sequel::Migrator.run DB, 'db/migrations', :target => 0
      Sequel::Migrator.run DB, 'db/migrations'
      puts "<= db:migrate:auto executed"
    end

    desc "Perform migration up/down to VERSION"
    task :to, :version do |t, args|
      version = (args[:version] || ENV['VERSION']).to_s.strip
      raise "No VERSION was provided" if version.empty?
      Sequel::Migrator.apply DB, 'db/migrations', version.to_i
      puts "<= db:migrate:to[#{version}] executed"
    end

    desc "Perform migration up to latest migration available"
    task :up do
      Sequel::Migrator.run DB, 'db/migrations'
      puts "<= db:migrate:up executed"
    end

    desc "Perform migration down (erase all data)"
    task :down do
      Sequel::Migrator.run DB, 'db/migrations', :target => 0
      puts "<= db:migrate:down executed"
    end

    desc "Load the database with seed data."
    task :seed do
      Dir['app/models/*.rb'].each { |f| require f }
      seed_file = 'db/seed.rb'
      load(seed_file) if File.exists?(seed_file)
    end

    desc "Load the database with demo data."
    task :demo do
      Dir['app/models/*.rb'].each { |f| require f }
      seed_file = 'db/demo.rb'
      load(seed_file) if File.exists?(seed_file)
    end
  end
end
