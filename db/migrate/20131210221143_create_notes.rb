class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :watcher, index: true
      t.references :grouping, index: true
      t.text :message

      t.timestamps
    end
  end
end
