class ChangeGroupingStateActiveToUnacknowleged < ActiveRecord::Migration
  class Grouping < ActiveRecord::Base;  end
  class WatGrouping < ActiveRecord::Base;  end

  class Watcher < ActiveRecord::Base
    serialize :default_filters
  end

  def change
    change_column_default :groupings, :state, :unacknowledged

    Grouping.where(state: :active).update_all(state: :unacknowledged)
    WatsGrouping.where(state: :active).update_all(state: :unacknowledged)

    Watcher.find_each do |watcher|
      if watcher.default_filters.try(:[], "state").present?
        if watcher.default_filters["state"].include? "active"
          watcher.default_filters["state"] << "unacknowledged"
          watcher.save!
        end
      end
    end
  end
end
