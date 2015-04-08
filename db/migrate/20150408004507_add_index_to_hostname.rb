class AddIndexToHostname < ActiveRecord::Migration
  def change
    add_index :wats, :hostname
  end
end
