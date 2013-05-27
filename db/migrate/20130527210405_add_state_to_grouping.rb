class AddStateToGrouping < ActiveRecord::Migration
  def change
    add_column :groupings, :state, :string, default: :active, null: false
    add_index :groupings, :state
  end
end
