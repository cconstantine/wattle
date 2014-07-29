class GroupingUnsubscribe < ActiveRecord::Base

  belongs_to :grouping
  belongs_to :watcher

  validates :grouping, presence: true
  validates :watcher, presence: true
end
