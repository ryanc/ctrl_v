app_path = File.expand_path(File.expand_path(File.dirname(__FILE__)) + '/../')
working_directory app_path

worker_processes (ENV['UNICORN_WORKERS'] || 2).to_i

listen "#{app_path}/tmp/sockets/unicorn.sock"
listen 8080

pid "#{app_path}/tmp/pids/unicorn.pid"

stderr_path "#{app_path}/log/unicorn.stderr.log"
stdout_path "#{app_path}/log/unicorn.stdout.log"

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(DB) and
    DB.disconnect
end
