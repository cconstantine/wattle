class GroupingReindexer
  include Sidekiq::Worker

  DEBOUNCE_DELAY = 10.minutes

  def self.debounce_enqueue(grouping_id)
    Sidekiq.redis do |redis|
      now = Time.zone.now.to_i
      key_name = "#{self.name}.perform(#{grouping_id})#DEBOUNCE1"

      lock_count = redis.incr(key_name)
      if lock_count == 1
        redis.expire(key_name, now + DEBOUNCE_DELAY)
        self.perform_async(grouping_id)
      elsif lock_count == 2
        self.perform_in( now + DEBOUNCE_DELAY , grouping_id)
      end
    end
  end

  def perform(grouping_id)
    Grouping.find(grouping_id).reindex
  end

  def wat_user(grouping_id)
    {id: "grouping_#{grouping_id}"}
  end

end
