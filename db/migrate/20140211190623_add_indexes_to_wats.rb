class AddIndexesToWats < ActiveRecord::Migration
  def change
    add_index :wats, :created_at
  end
end
