class StreamEvent < ActiveRecord::Base
  belongs_to :grouping
  belongs_to :context, polymorphic: true

  before_save :ensure_happened_at


  after_commit :send_email, on: :create unless Rails.env.test?
  after_create :send_email              if     Rails.env.test?

  def ensure_happened_at
    self.happened_at ||= Time.zone.now
  end

  def send_email

  end
end
