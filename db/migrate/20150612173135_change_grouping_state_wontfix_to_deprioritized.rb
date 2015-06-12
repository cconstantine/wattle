class ChangeGroupingStateWontfixToDeprioritized < ActiveRecord::Migration
  class Grouping < ActiveRecord::Base;  end
  class WatGrouping < ActiveRecord::Base;  end

  class Watcher < ActiveRecord::Base
    serialize :default_filters
  end

  def change

    Grouping.where(state: :wontfix).update_all(state: :deprioritized)
    WatsGrouping.where(state: :wontfix).update_all(state: :deprioritized)

    Watcher.find_each do |watcher|
      if watcher.default_filters.try(:[], "state").present?
        if watcher.default_filters["state"].include? "wontfix"
          watcher.default_filters["state"] << "deprioritized"
          watcher.save!
        end
      end
    end
  end
end
