class GroupingVersion < PaperTrail::Version
  after_create :create_event
  belongs_to :watcher, foreign_key: :whodunnit
  has_one :stream_event, as: :context


  def create_event
    build_stream_event(grouping_id: reify.id).save! if reify.present?
  end
end
