class WatsGrouping < ActiveRecord::Base
  belongs_to :wat
  belongs_to :grouping, counter_cache: :wats_count

  validates :wat, presence: true
  validates :grouping, presence: true
end
