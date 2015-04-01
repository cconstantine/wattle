class AddApiKeyToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :api_key, :string
  end
end
