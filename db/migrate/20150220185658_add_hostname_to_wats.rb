class AddHostnameToWats < ActiveRecord::Migration
  def change
    add_column :wats, :hostname, :text
  end
end
