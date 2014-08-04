class AddEmailFiltersToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :email_filters, :text
  end
end
