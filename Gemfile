source 'https://rubygems.org'

gem 'rails', github: 'rails/rails', branch: 'v4.0.0.rc1'

gem 'pg'

gem "haml-rails"
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'

gem 'httpclient'
gem 'wat_catcher'
gem 'kaminari'
gem 'omniauth-gplus'
gem 'secrets', :github => "austinfromboston/secrets"
gem 'state_machine'

group :production do
  #Use unicorn as the app server
  gem 'unicorn'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'
  gem 'bootstrap-sass', '~> 2.3.1.0'
  gem "backbone-on-rails"
  #gem 'underscore-rails'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'mailcatcher'
end

group :test, :development do
  gem 'fixture_builder'
  gem 'thin'
end

group :test do
  gem 'email_spec'
  gem "rspec-rails", "~> 2.0"
end