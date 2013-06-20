class AddAppEnvToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :app_env, :string
    add_index :groupings, :app_env
  end
end
