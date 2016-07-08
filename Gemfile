source 'https://rubygems.org'

#ruby File.read(".ruby-version").strip#'2.1.1'
gem 'rails'#, "~> 4.2"
gem 'pg'
gem "haml-rails"
gem 'jquery-rails'
gem 'jbuilder', '~> 1.0.1'
gem 'httpclient'
gem 'wat_catcher'#, path: "../wat_catcher"
gem 'sidekiq_healthcheck'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'omniauth-gplus'
gem 'secrets', :github => "austinfromboston/secrets"
gem 'state_machine', :github => "seuros/state_machine"
gem 'user-agent'
gem 'redcarpet'
gem 'sass-rails',   '>= 4.0'
gem 'coffee-rails', '>= 4.0'
gem 'bootstrap-sass-rails'
gem "backbone-on-rails"
gem 'uglifier', '>= 1.0.3'
gem 'execjs'
gem 'therubyracer'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'redis-semaphore'
gem 'slim', ">= 1.3.0", :require => false
gem 'sinatra', '>= 1.3.0', :require => false
gem 'highcharts-rails'
gem 'moment_ago'
gem 'libv8', '=3.16.14.7'
gem 'puma'
gem "logviously", git: 'git@github.com:omadahealth/logviously'
gem 'newrelic_rpm'
gem 'paper_trail'
gem 'searchkick'
gem 'typhoeus'
gem 'responders', '~> 2.0'
gem 'cancancan'
gem 'dotenv-rails'
gem 'foreman'
gem 'health_check'
gem 'rack-timeout'
gem 'tracker_api'

gem 'apohypaton'

group :production do
  gem 'rails_12factor'
end

group :development do
  gem 'pivotal_git_scripts'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'

  gem 'capistrano', '>= 3.4.0'
  gem 'capistrano-rails'
end

group :test, :development do
  gem 'awesome_print'
  gem 'rr', require: false
  gem 'rspec-rails'#, "~> 2"
  gem 'fixture_builder'
  gem 'json_spec'
end

group :test do
  gem 'email_spec'
  gem 'capybara'
  gem 'poltergeist'
  gem "poltergeist-suppressor"
  gem 'launchy'
  gem 'rspec-collection_matchers'
end
