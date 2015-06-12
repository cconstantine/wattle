class WatsGrouping < ActiveRecord::Base
  belongs_to :wat
  belongs_to :grouping

  validates :wat, presence: true
  validates :grouping, presence: true

  before_create :set_state


  state_machine :state, initial: :unacknowledged do
    state :unacknowledged, :resolved, :deprioritized, :acknowledged

    event :activate do
      transition [:resolved, :deprioritized] => :unacknowledged
    end

    event :resolve do
      transition [:deprioritized, :unacknowledged] => :resolved
    end

    event :deprioritized do
      transition :unacknowledged => :deprioritized
    end

    event :acknowledge do
      transition [:deprioritized, :unacknowledged] => :acknowledged
    end
  end

  scope :open,          -> {where.not(state: :resolved)}
  scope :unacknowledged,        -> {where(state: :unacknowledged)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :deprioritized,       -> {where(state: :deprioritized)}
  scope :acknowledged,       -> {where(state: :deprioritized)}


  def set_state
    self.state = grouping.state
  end

  def destroy
    super
    grouping.destroy if grouping.reload.wats.empty?
  end
end
