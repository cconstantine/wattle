class GroupingOwner < ActiveRecord::Base
  belongs_to :grouping
  belongs_to :watcher

  validate :grouping, presence: true
  validate :watcher, presence: true
end
