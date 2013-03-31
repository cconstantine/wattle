class CreateGroupings < ActiveRecord::Migration
  def change
    create_table :groupings do |t|
      t.string :key_line
      t.string :error_class

      t.timestamps
    end
    add_index :groupings, [:key_line, :error_class]
  end
end
