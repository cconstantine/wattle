
class TmpGrouping < ActiveRecord::Base
  self.table_name = "groupings"
end

class TmpWatsGrouping < ActiveRecord::Base
  self.table_name = "wats_groupings"
end

class AddStateToWatsGrouping < ActiveRecord::Migration
  def up
    add_column :wats_groupings, :state, :string

    TmpWatsGrouping.update_all(state: :active)

    change_column :wats_groupings, :state, :string, null: false
    add_index :wats_groupings, [:state, :grouping_id, :wat_id]
  end

  def down
    remove_column :wats_groupings, :state
  end
end
