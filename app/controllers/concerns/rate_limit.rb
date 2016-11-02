module RateLimit
  extend ActiveSupport::Concern

  class RateLimitExceeded < StandardError; end

  included do
    around_filter :rate_limit
  end

  def rate_limit
    key_name = "ratelimit_#{rate_limit_key}"

    lock_count = $redis.incr(key_name)
    $redis.expire(key_name, 5.minutes)

    if lock_count > 3
      raise RateLimitExceeded.new("Current concurrency of #{lock_count} is greater than the 3 allowed.")
    end

    yield

  ensure
    $redis.decr(key_name)
  end


  def rate_limit_key
    return "user_#{current_user.id}" if current_user.present?
    return "remote_ip_#{request.remote_ip.gsub(".", "_")}"
  end
end