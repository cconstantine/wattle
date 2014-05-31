class AddMergedIntoGroupingIdToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :merged_into_grouping_id, :integer
    add_index  :groupings, :merged_into_grouping_id
  end
end
