class AddRequestParamsToWat < ActiveRecord::Migration
  def change
    add_column :wats, :request_params, :hstore
  end
end
