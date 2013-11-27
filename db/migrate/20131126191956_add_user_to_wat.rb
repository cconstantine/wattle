class AddUserToWat < ActiveRecord::Migration
  def up
    add_column :wats, :app_user, :hstore, default: {id: nil}
    execute 'CREATE INDEX wats_user_index ON wats USING GIN(app_user)'
  end

  def down
    remove_column :wats, :app_user
  end
end
