require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

# Configure secrets management gem
Apohypaton.configure do |conf|
  conf.url = URI(ENV['APOHYPATON_CONSUL_URL'] || 'consul://consul.omadahealth.net:443')
  conf.token = ENV['APOHYPATON_CONSUL_TOKEN'] || ENV['WATTLE_CONSUL_TOKEN']
  conf.app_name = 'wattle'
  conf.enabled = (Rails.env.development? || Rails.env.test?) ? false : true
end

class WatConfig
  def self.secret_value(key)
    ENV[key] || Apohypaton::Kv.load_secret("secrets/" + key)
  end
end

module Wattle
  class ConfigureMailer < Rails::Railtie
    initializer "configure_mailer.set_config", after: "secrets.load" do |app|
      url_options = ::Secret.default_url_options.to_h.symbolize_keys || {}

      url_options[:host] ||= ::WatConfig.secret_value('DEFAULT_URL_OPTIONS_HOST') || WatCatcher.configuration.host || "localhost"
      url_options[:port] ||= ::WatConfig.secret_value('DEFAULT_URL_OPTIONS_PORT') if ::WatConfig.secret_value('DEFAULT_URL_OPTIONS_PORT').present?
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

    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :sidekiq

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.js *.woff *.ttf *.svg wats.css)

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { :address => ::WatConfig.secret_value("SMTP_HOST") || WatConfig.secret_value("DOKKU_HOST") || "localhost", :port => WatConfig.secret_value("SMTP_PORT") || 25 }

    config.middleware.use(WatCatcher::RackMiddleware)

    config.autoload_paths += %W(#{config.root}/app/workers/concerns)
    config.logger = Logviously.configure(config)

    ::Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add ::WatCatcher::SidekiqMiddleware
      end
    end
  end
end
