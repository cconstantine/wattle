class StreamEvent < ActiveRecord::Base
  belongs_to :grouping
  belongs_to :context, polymorphic: true

  before_save :ensure_happened_at

  def ensure_happened_at
    self.happened_at ||= Time.zone.now
  end
end
