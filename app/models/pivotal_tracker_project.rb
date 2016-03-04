class PivotalTrackerProject < ActiveRecord::Base
  belongs_to :watcher

  validates :tracker_id, :name, presence: true
end
