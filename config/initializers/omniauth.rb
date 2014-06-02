Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  if ENV['GOOGLE_KEY'].present? || Secret.respond_to?(:google_key)
    provider :gplus, ENV['GOOGLE_KEY'] || Secret.google_key, ENV['GOOGLE_SECRET'] || Secret.google_secret, scope: 'userinfo.email, userinfo.profile'
  end
end
OmniAuth.config.logger = Rails.logger

