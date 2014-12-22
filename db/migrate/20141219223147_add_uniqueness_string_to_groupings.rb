class AddUniquenessStringToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :uniqueness_string, :string
    execute "UPDATE groupings SET uniqueness_string = id"
    change_column :groupings, :uniqueness_string, :string, null: false
    add_index :groupings, :uniqueness_string, unique: true, where: "state != 'resolved'"
  end
end
