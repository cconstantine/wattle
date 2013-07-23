class MyWat < ActiveRecord::Base
  self.table_name = 'wats'
end

class ChangeBacktranceToTextArray < ActiveRecord::Migration
  def up
    add_column :wats, :backtrace_new, :text, array: true
    MyWat.all.each do |wat|
      wat.update_attributes!(backtrace_new: wat.backtrace)
    end
    remove_column :wats, :backtrace
    rename_column :wats, :backtrace_new, :backtrace
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
