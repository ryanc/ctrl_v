worker_processes 2
pid "/srv/apps/ctrl_v/shared/pids/unicorn.pid"
stderr_path "/srv/apps/ctrl_v/shared/log/unicorn.stderr.log"
stdout_path "/srv/apps/ctrl_v/shared/log/unicorn.stdout.log"
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true
