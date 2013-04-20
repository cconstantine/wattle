class AddSessionToWat < ActiveRecord::Migration
  def change
    add_column :wats, :session, :hstore
  end
end
