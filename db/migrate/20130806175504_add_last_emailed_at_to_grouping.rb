class AddLastEmailedAtToGrouping < ActiveRecord::Migration
  def change
    add_column :groupings, :last_emailed_at, :datetime
  end
end
