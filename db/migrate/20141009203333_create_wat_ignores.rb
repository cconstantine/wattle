class CreateWatIgnores < ActiveRecord::Migration
  def change
    create_table :wat_ignores do |t|
      t.text :user_agent
      t.timestamps
    end

    add_index :wat_ignores, :user_agent
  end
end
