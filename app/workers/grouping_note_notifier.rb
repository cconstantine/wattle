class GroupingNoteNotifier
  include Sidekiq::Worker

  DEBOUNCE_DELAY = 60.minutes
  SIDEKIQ_NOTIFY_AFTER = 10.minutes

  attr_accessor :grouping

  class << self
    def notify(grouping_id)
      GroupingNoteNotifier.new(Grouping.find(grouping_id)).perform
    end

    def wat_user(grouping_id)
      {id: "grouping_#{grouping_id}"}
    end
  end

  def initialize(grouping)
    self.grouping = grouping
  end

  def perform
    Sidekiq::redis do |redis|
      Redis::Semaphore.new(:GroupingNotifierSemaphore, :connection => redis).lock(1.hour) do
        grouping.reload
        return unless needs_notifying?
        if send_email_now?
          send_email
          mark_as_sent
        else
          send_email_later
        end
      end
    end
  end

  def send_email_now?
    grouping.active? && (grouping.last_emailed_at.nil? ||  (grouping.last_emailed_at <= Time.zone.now - DEBOUNCE_DELAY))
  end

  def needs_notifying?
    return false if grouping.app_envs.include? 'honeypot'
    return false if grouping.muffled?
    (grouping.active? || grouping.muffled?) && grouping.last_emailed_at.nil?
  end

  def email_recipients
    potential_watchers = grouping.owners.any? ? grouping.owners : Watcher.active
    potential_watchers.map do |watcher|
      next if grouping.unsubscribed?(watcher)
      next unless Grouping.where(id: grouping.to_param).filtered(watcher.email_filters).any?
      watcher
    end.compact
  end

  def send_email
    Rails.logger.info("Sending email for grouping #{grouping.id}")
    email_recipients.each do |watcher|
      GroupingMailer.delay.notify_about_note(watcher, grouping)
    end
  end

  private

  def mark_as_sent
    grouping.update_attributes!(last_emailed_at: Time.zone.now)
  end

  def send_email_later
    Rails.logger.info("Delaying notification for grouping #{grouping.id}")
    GroupingNoteNotifier.delay_for(DEBOUNCE_DELAY).notify(grouping.id) unless Rails.env.test?
  end
end
