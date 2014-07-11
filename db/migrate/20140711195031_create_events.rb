class CreateEvents < ActiveRecord::Migration
  def up
    create_table :stream_events do |t|
      t.datetime :happened_at, null: false
      t.references :grouping, index: true, null: false
      t.references :context,  index: true, null: false, polymorphic: true

      t.timestamps
    end

    add_index :stream_events, [:happened_at, :grouping_id]

    execute <<SQL
INSERT INTO stream_events (happened_at, grouping_id, context_id, context_type, created_at, updated_at) (SELECT notes.created_at, notes.grouping_id, notes.id, 'Note', now(), now() from notes)
SQL
  end

  def down
    drop_table :stream_events
  end
end
