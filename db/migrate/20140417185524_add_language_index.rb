class AddLanguageIndex < ActiveRecord::Migration
  def change
    add_index :wats, :language
  end
end
