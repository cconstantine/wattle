class RemoveWatsGroupingTable < ActiveRecord::Migration
  def change
    drop_table :wats_groupings
  end
end
