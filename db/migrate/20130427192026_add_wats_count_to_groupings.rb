class AddWatsCountToGroupings < ActiveRecord::Migration

  def up
    add_column :groupings, :wats_count, :integer
    Grouping.pluck(:id).each do |grouping_id|
      Grouping.reset_counters grouping_id, :wats
    end
  end

  def down
    remove_column :groupings, :wats_count, :integer
  end
end
