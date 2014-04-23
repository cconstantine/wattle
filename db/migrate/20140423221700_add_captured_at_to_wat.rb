class AddCapturedAtToWat < ActiveRecord::Migration
  def up
    add_column :wats, :captured_at, :datetime
    execute <<-SQL
UPDATE wats SET captured_at = created_at;
    SQL

    add_index :wats, :captured_at
    change_column :wats, :captured_at, :datetime, null: false
  end

  def down
    remove_column :wats, :captured_at

  end
end
