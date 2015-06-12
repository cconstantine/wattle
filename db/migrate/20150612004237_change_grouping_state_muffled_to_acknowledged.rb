class ChangeGroupingStateMuffledToAcknowledged < ActiveRecord::Migration
  class Grouping < ActiveRecord::Base;  end
  class WatGrouping < ActiveRecord::Base;  end

  class Watcher < ActiveRecord::Base
    serialize :default_filters
  end

  def change

    Grouping.where(state: :muffled).update_all(state: :acknowledged)
    WatsGrouping.where(state: :muffled).update_all(state: :acknowledged)

    Watcher.find_each do |watcher|
      if watcher.default_filters.try(:[], "state").present?
        if watcher.default_filters["state"].include? "muffled"
          watcher.default_filters["state"] << "acknowledged"
          watcher.save!
        end
      end
    end
  end

end
