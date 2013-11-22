class RemoveWatsCountFromGrouping < ActiveRecord::Migration
  def change
    remove_column :groupings, :wats_count, :integer
  end
end
