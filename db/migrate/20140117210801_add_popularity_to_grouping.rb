class AddPopularityToGrouping < ActiveRecord::Migration
  def change
    add_column :groupings, :popularity, :'numeric(1000,1)'

    add_index :groupings, :popularity
  end
end
