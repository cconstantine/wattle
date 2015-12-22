class AddComplexWatIndexes < ActiveRecord::Migration
  def change
    add_index "wats", [:grouping_id, :app_env, :app_name, :app_user, :hostname], name: :gaaah_index
    add_index "wats", [:grouping_id, :app_env, :app_name, :hostname], name: :gaah_index

    add_index "wats", [:grouping_id, :app_env, :app_user, :hostname], name: :gaah2_index
    add_index "wats", [:grouping_id, :app_env, :hostname], name: :gah_index

    add_index "wats", [:grouping_id, :app_name, :app_user, :hostname], name: :gaah3_index
    add_index "wats", [:grouping_id, :app_user, :hostname], name: :gah2_index
    add_index "wats", [:grouping_id, :hostname], name: :ga_index
  end
end
