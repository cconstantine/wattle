class CreateGroupingOwners < ActiveRecord::Migration
  def change
    create_table :grouping_owners do |t|
      t.references :grouping, index: true
      t.references :watcher

      t.timestamps
    end

    add_index :grouping_owners, [:watcher_id, :grouping_id], unique: true
  end
end
