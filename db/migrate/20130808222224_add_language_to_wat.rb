class AddLanguageToWat < ActiveRecord::Migration
  def change
    add_column :wats, :language, :string
  end
end
