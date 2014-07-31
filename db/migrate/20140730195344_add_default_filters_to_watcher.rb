class AddDefaultFiltersToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :default_filters, :text
  end
end
