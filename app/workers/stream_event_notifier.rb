class StreamEventNotifier
  include Sidekiq::Worker

  attr_accessor :stream_event

  class << self
    def notify(stream_id)
      StreamEventNotifier.new(StreamEvent.find(stream_id)).perform
    end

    def wat_user(stream_id)
      {id: "stream_event_#{stream_id}"}
    end
  end

  def initialize(stream_event)
    self.stream_event = stream_event
  end

  def perform
    Rails.logger.info("Sending email for stream_event #{stream_event.id}")
    grouping.email_recipients.each do |watcher|
      StreamEventMailer.delay.notify(watcher, stream_event)
    end
  end

end
