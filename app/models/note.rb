class Note < ActiveRecord::Base
  belongs_to :watcher
  belongs_to :grouping

  has_one :stream_event, as: :context

  after_create :create_event

  after_commit :send_email, on: :create unless Rails.env.test?
  after_create :send_email              if     Rails.env.test?

  validates :grouping, presence: true
  validates :watcher , presence: true

  def create_event
    build_stream_event(grouping: grouping).save!
  end

  def send_email
    GroupingNoteNotifier.delay.notify grouping.id
  end
end
