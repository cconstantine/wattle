workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

rackup      DefaultRackup

rails_root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
bind "unix://#{ File.join(rails_root,'sockets','app.sock') }"

stdout_redirect File.join(rails_root, 'log', 'puma.stdout.log'), File.join(rails_root, 'log', 'puma.stderr.log'), true
