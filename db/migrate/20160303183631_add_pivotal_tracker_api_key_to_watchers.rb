class AddPivotalTrackerApiKeyToWatchers < ActiveRecord::Migration
  def change
    add_column :watchers, :pivotal_tracker_api_key, :string
  end
end
