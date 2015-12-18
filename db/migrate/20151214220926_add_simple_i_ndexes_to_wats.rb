class AddSimpleINdexesToWats < ActiveRecord::Migration
  def change
    add_index :wats, [:captured_at, :grouping_id]
    add_index :wats, [:id, :captured_at, :grouping_id]
    add_index :wats, [:grouping_id, :app_user]
    add_index :groupings, :uniqueness_string, name: :index_groupings_on_uniqueness_string_search
  end
end
