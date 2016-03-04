class CreatePivotalTrackerProjects < ActiveRecord::Migration
  def change
    create_table :pivotal_tracker_projects do |t|
      t.text :name
      t.string :tracker_id
      t.references :watcher, index: true
      t.timestamps
    end
  end
end
