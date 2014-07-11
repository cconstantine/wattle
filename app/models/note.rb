class Note < ActiveRecord::Base
  belongs_to :watcher
  belongs_to :grouping

  has_one :stream_event, as: :context

  after_create :create_event

  validates :grouping, presence: true
  validates :watcher , presence: true

  def create_event
    build_stream_event(grouping: grouping).save!
  end
end
