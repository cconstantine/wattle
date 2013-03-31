class CreateWats < ActiveRecord::Migration
  def change
    create_table :wats do |t|
      t.string :backtrace, array: true
      t.text :message
      t.string :error_class

      t.timestamps
    end
  end
end
