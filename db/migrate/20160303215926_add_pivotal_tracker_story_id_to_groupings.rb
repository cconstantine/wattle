class AddPivotalTrackerStoryIdToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :pivotal_tracker_story_id, :string
  end
end
