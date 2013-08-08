class AddMessageToGrouping < ActiveRecord::Migration
  def change
    add_column :groupings, :message, :text

    add_index :groupings, :message
  end
end
