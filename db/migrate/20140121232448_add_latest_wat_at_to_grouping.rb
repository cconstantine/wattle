class AddLatestWatAtToGrouping < ActiveRecord::Migration

  class Grouping < ActiveRecord::Base
    has_many :wats_groupings
    has_many :wats, through: :wats_groupings
  end

  class WatsGrouping < ActiveRecord::Base
    belongs_to :wat
    belongs_to :grouping
  end

  class Wat < ActiveRecord::Base; end

  def change
    add_column :groupings, :latest_wat_at, :datetime
    add_index  :groupings, :latest_wat_at

    Grouping.find_each do |grouping|
      grouping.update_column(:latest_wat_at, grouping.wats.last.created_at)
    end

  end
end
