class AddAppEnvToWat < ActiveRecord::Migration
  def change
    add_column :wats, :app_env, :string, default: :unknown, null: false
    add_index :wats, :app_env
  end
end
