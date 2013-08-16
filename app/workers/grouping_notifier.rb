class GroupingNotifier < Struct.new(:grouping)
  include Sidekiq::Worker

  DEBOUNCE_DELAY = 10.minutes

  class << self
    def notify(grouping_id)
      GroupingNotifier.new(Grouping.find(grouping_id)).perform
    end
  end

  def perform
    return unless needs_notifying?
    if send_email_now?
      send_email
    else
      send_email_later
    end
  end

  def send_email_now?
    grouping.active? && (grouping.last_emailed_at.nil? ||  grouping.last_emailed_at <= Time.zone.now - DEBOUNCE_DELAY)
  end

  def wats
    grouping.wats
  end

  def needs_notifying?
    return false if grouping.is_javascript? && js_wats_per_hour_in_previous_day > js_wats_in_previous_hour / 2
    grouping.active? && (grouping.last_emailed_at.nil? || grouping.wats.where("wats.created_at > ?", grouping.last_emailed_at).any?)
  end

  def js_wats_per_hour_in_previous_day
    Wat.javascript.open.after(24.day.ago).count / 24
  end

  def js_wats_in_previous_hour
    Wat.javascript.open.after(1.day.ago).count
  end

  private

  def send_email
    Rails.logger.info("Sending email for grouping #{grouping.id}")
    GroupingMailer.delay.notify(grouping)
    grouping.update_attributes!(last_emailed_at: Time.zone.now)
  end

  def send_email_later
    Rails.logger.info("Delaying notification for grouping #{grouping.id}")
    GroupingNotifier.delay_for(DEBOUNCE_DELAY).notify(grouping.id) unless Rails.env.test?
  end
end