class Note < ActiveRecord::Base
  belongs_to :watcher
  belongs_to :grouping

  validates :grouping, presence: true
  validates :watcher , presence: true
end
