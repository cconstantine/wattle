workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'


if Rails.env.production?
  daemonize true
  pidfile Rails.root.join('tmp','pids', 'puma.pid')
  stdout_redirect Rails.root.join('log', 'puma.stdout.log'), Rails.root.join('log', 'puma.stderr.log'), true
end

