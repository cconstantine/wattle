class AddSidekiqMsgToWat < ActiveRecord::Migration
  def change
    add_column :wats, :sidekiq_msg, :hstore
  end
end
