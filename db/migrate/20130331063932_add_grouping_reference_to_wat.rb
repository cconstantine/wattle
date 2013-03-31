class AddGroupingReferenceToWat < ActiveRecord::Migration
  def change
    add_reference :wats, :grouping, index: true
  end
end
