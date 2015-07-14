class AddRailsRootToWat < ActiveRecord::Migration
  def change
    add_column :wats, :rails_root, :text
  end
end
