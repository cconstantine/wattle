class AddStateToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :state, :string, default: "active", null: false
  end
end
