class WatsGrouping < ActiveRecord::Base
  belongs_to :wat
  belongs_to :grouping

  validates :wat, presence: true
  validates :grouping, presence: true
end
