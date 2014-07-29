class CreateGroupingUnsubscribes < ActiveRecord::Migration
  def change
    create_table :grouping_unsubscribes do |t|
      t.references :watcher
      t.references :grouping

      t.timestamps
    end

    add_index :grouping_unsubscribes, [:watcher_id, :grouping_id], unique: true
  end
end
