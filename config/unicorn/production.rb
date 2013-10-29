## Config file for unicorn servers
## unicorn should be started from base rails dir
RAILS_ROOT = '/var/www/wattle/current'

worker_processes 4
working_directory "#{RAILS_ROOT}"

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "/var/www/wattle/shared/sockets/unicorn.sock", :backlog => 64

pid "#{RAILS_ROOT}/tmp/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{RAILS_ROOT}/log/unicorn.stderr.log"
stdout_path "#{RAILS_ROOT}/log/unicorn.stdout.log"

before_fork do |server, worker|

  # This option works in together with preload_app true setting
  # What is does is prevent the master process from holding
  # the database connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  # Here we are establishing the connection after forking worker
  # processes
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
