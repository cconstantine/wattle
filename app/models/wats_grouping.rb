class WatsGrouping < ActiveRecord::Base
  belongs_to :wat
  belongs_to :grouping

  validates :wat, presence: true
  validates :grouping, presence: true

  before_create :set_state


  state_machine :state, initial: :unacknowledged do
    state :unacknowledged, :resolved, :wontfix, :muffled

    event :activate do
      transition [:resolved, :wontfix] => :unacknowledged
    end

    event :resolve do
      transition [:wontfix, :unacknowledged] => :resolved
    end

    event :wontfix do
      transition :unacknowledged => :wontfix
    end

    event :muffle do
      transition [:wontfix, :unacknowledged] => :muffled
    end
  end

  scope :open,          -> {where.not(state: :resolved)}
  scope :unacknowledged,        -> {where(state: :unacknowledged)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :wontfix,       -> {where(state: :wontfix)}
  scope :muffled,       -> {where(state: :wontfix)}


  def set_state
    self.state = grouping.state
  end

  def destroy
    super
    grouping.destroy if grouping.reload.wats.empty?
  end
end
