class RemovePopularityFromGroupings < ActiveRecord::Migration
  def change
    remove_column :groupings, :popularity, :'numeric(1000,1)'
  end
end
