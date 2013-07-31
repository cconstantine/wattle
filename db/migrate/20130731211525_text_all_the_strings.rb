class TextAllTheStrings < ActiveRecord::Migration
  def up
    change_column :wats, :page_url, :text
    change_column :wats, :error_class, :text
    change_column :wats, :app_env, :text
    change_column :wats, :app_name, :text
  end
  def down
    change_column :wats, :page_url, :string
    change_column :wats, :error_class, :string
    change_column :wats, :app_env, :string
    change_column :wats, :app_name, :string
  end
end
