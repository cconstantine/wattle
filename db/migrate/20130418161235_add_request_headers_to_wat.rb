class AddRequestHeadersToWat < ActiveRecord::Migration
  def change
    add_column :wats, :request_headers, :hstore
  end
end
