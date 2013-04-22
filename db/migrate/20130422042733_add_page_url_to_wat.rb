class AddPageUrlToWat < ActiveRecord::Migration
  def change
    add_column :wats, :page_url, :string
  end
end
