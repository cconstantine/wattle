class AddAppNameToWats < ActiveRecord::Migration
  def change
    add_column :wats, :app_name, :string, default: :unknown, null: false
    add_index :wats, :app_name
  end
end
