require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

module Wattle
  class ConfigureMailer < Rails::Railtie
    initializer "configure_mailer.set_config", after: "secrets.load" do |app|

      #Default url options from environment variables if availble
      if ENV['DEFAULT_URL_OPTIONS_HOST'].present? || ENV['DEFAULT_URL_OPTIONS_PORT'].present?
        url_options = {
          host: ENV['DEFAULT_URL_OPTIONS_HOST'] || 'localhost',
          port: ENV['DEFAULT_URL_OPTIONS_PORT'] || 3001
        }
      else
        url_options = ::Secret.default_url_options.to_h.symbolize_keys
      end

      app.config.action_mailer.default_url_options = url_options
    end
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de


    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.js *.woff *.ttf *.svg wats.css)

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { :address => ENV["SMTP_HOST"] || "localhost", :port => ENV["SMTP_PORT"] || 25 }

    config.middleware.use(WatCatcher::RackMiddleware)

    ::Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add ::WatCatcher::SidekiqMiddleware
      end
    end
  end
end
