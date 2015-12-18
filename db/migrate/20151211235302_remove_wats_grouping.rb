class RemoveWatsGrouping < ActiveRecord::Migration
  def up
    add_column :wats, :grouping_id, :integer

    connection.execute <<-SQL
UPDATE wats
 SET grouping_id = wats_groupings.grouping_id
 FROM wats_groupings join groupings on wats_groupings.grouping_id = groupings.id

 WHERE ( wats_groupings.state != 'resolved' AND wats_groupings.wat_id = wats.id )
SQL

    add_index :wats, :grouping_id
  end

  def down
    remove_column :wats, :grouping_id
  end
end
