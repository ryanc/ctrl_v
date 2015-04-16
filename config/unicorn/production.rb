shared_path = File.expand_path('../../../shared', File.dirname(__FILE__))
current_path = File.expand_path('../../../current', File.dirname(__FILE__))

working_directory current_path

worker_processes (ENV['UNICORN_WORKERS'] || 3).to_i

listen "#{shared_path}/tmp/sockets/unicorn.sock"
listen 8080

pid "#{shared_path}/tmp/pids/unicorn.pid"

stderr_path "#{current_path}/log/unicorn.stderr.log"
stdout_path "#{current_path}/log/unicorn.stdout.log"

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(DB) and
    DB.disconnect

  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{current_path}/Gemfile"
end
