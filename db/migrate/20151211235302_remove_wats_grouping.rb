class RemoveWatsGrouping < ActiveRecord::Migration
  class WatsGrouping < ActiveRecord::Base
    belongs_to :wat
    belongs_to :grouping
  end

  class Wat < ActiveRecord::Base
    has_many :wats_groupings, dependent: :destroy
    has_many :groupings, through: :wats_groupings
  end


  class Grouping < ActiveRecord::Base
    has_many :wats_groupings
    has_many :open_wats_groupings, -> { where.not(state: :resolved) }, class_name: "WatsGrouping"
    has_many :wats, through: :open_wats_groupings
    has_many :all_wats, through: :wats_groupings
    has_many :new_wats, ->(grouping) { grouping.last_emailed_at.present? ? where('wats.created_at > ?', grouping.last_emailed_at) : self }, class_name: "Wat", through: :wats_groupings, source: :wat

  end



  def change
    add_column :wats, :grouping_id, :integer

    Grouping.find_each do |grouping|
      grouping.wats.update_all(grouping_id: grouping.id)
    end
    add_index :wats, :grouping_id

    add_column :groupings, :previous_grouping_id, :integer

    Grouping.find_each do |grouping|
      grouping.update_column :previous_grouping_id, grouping.wats.last.groupings.where.not(id: grouping.id).last.try(:grouping).try(:id)
    end

    drop_table :wats_groupings
  end
end
