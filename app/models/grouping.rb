class Grouping < ActiveRecord::Base
  has_many :wats_groupings
  has_many :wats, through: :wats_groupings

  scope( :wat_order, -> { joins(:wats).group(:"groupings.id").reorder("max(wats.id) asc") } ) do
      def reverse
        reorder("max(wats.id) desc")
      end
  end

  def self.get_or_create_from_wat!(wat)
    transaction do
      where(error_class: wat.error_class, key_line: wat.key_line).first_or_create!
    end
  end

end
