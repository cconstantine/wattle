module Debounce
  extend ActiveSupport::Concern

  module ClassMethods
    def debounce_enqueue(grouping_id, time_delay)
      Sidekiq.redis do |redis|
        now = Time.zone.now.to_i
        key_name = "#{self.name}.perform(#{grouping_id})#DEBOUNCE1"

        lock_count = redis.incr(key_name)
        if lock_count == 1
          redis.expire(key_name, now + time_delay)
          self.perform_async(grouping_id)
        elsif lock_count == 2
          self.perform_in( now + time_delay , grouping_id)
        end
      end
    end
  end
end
