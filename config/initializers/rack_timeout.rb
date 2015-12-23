
Rack::Timeout.timeout = Rails.env.production? ? 60 : false