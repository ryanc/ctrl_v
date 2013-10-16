application = "ctrl_v"
deploy_to = "/srv/apps/#{application}"
shared_path = "#{deploy_to}/shared"

worker_processes 2
listen "#{shared_path}/tmp/sockets/unicorn.sock"
pid "#{shared_path}/tmp/pids/unicorn.pid"
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true
