# config valid only for current version of Capistrano
lock '3.6.1'

set :branch, ENV['BRANCH'] || `git rev-parse HEAD`.split.first

set :application, 'wattle'
set :repo_url, 'git@github.com:omadahealth/wattle.git'


# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', '.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'sockets', 'vendor/bundle' )

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :puma do
  task :start do
    on roles :web do
      execute :sudo, 'service', 'wattle-rails', 'start'
    end
  end
  task :stop do
    on roles :web do
      execute :sudo, 'service', 'wattle-rails', 'stop'
    end
  end
  task :restart do
    on roles :web do
      execute "sudo service wattle-rails reload || sudo service wattle-rails start"
    end
  end
end

namespace :sidekiq do
  task :start do
    on roles :jobs do
      execute :sudo, 'service', 'wattle-sidekiq', 'start'
    end
  end
  task :stop do
    on roles :jobs do
      execute :sudo, 'service', 'wattle-sidekiq', 'stop'
    end
  end
  task :restart do
    on roles :jobs do
      execute :sudo, 'service', 'wattle-sidekiq', 'restart'
    end
  end
end

before "deploy:updated", "deploy:migrate"

after "deploy:published", "puma:restart"
after "deploy:published", "sidekiq:restart"

