Rails.application.config.middleware.use OmniAuth::Builder do
  if WatConfig.secret_value('GOOGLE_KEY').present? || Secret.respond_to?(:google_key)
    provider :gplus, WatConfig.secret_value('GOOGLE_KEY') || Secret.google_key, WatConfig.secret_value('GOOGLE_SECRET') || Secret.google_secret, scope: 'userinfo.email, userinfo.profile'
  else
    provider :developer
  end
end
OmniAuth.config.logger = Rails.logger

