class CreateWatsGroupings < ActiveRecord::Migration
  def change
    create_table :wats_groupings do |t|
      t.references :wat, index: true, null: false
      t.references :grouping, index: true, null: false

      t.timestamps
    end
    add_index :wats_groupings, [:grouping_id, :wat_id], unique: true
    remove_column :wats, :grouping_id, :integer
  end
end
