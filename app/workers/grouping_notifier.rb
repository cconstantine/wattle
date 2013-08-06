class GroupingNotifier < Struct.new(:grouping)
  include Sidekiq::Worker

  DEBOUNCE_DELAY = 10.minutes

  class << self
    def notify(grouping_id)
      GroupingNotifier.new(Grouping.find(grouping_id)).perform
    end
  end

  def perform
    if send_email_now?
      send_email
    elsif grouping.active?
      send_email_later
    end
  end

  def send_email_now?
    grouping.active? && (grouping.last_emailed_at.nil? ||  grouping.last_emailed_at <= Time.zone.now - DEBOUNCE_DELAY)
  end

  private

  def send_email
    GroupingMailer.delay.notify(grouping)
    grouping.update_attributes!(last_emailed_at: Time.zone.now)
  end

  def send_email_later
    GroupingNotifier.delay_for(DEBOUNCE_DELAY).notify(grouping.id) unless Rails.env.test?
  end
end