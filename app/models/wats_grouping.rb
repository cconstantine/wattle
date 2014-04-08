class WatsGrouping < ActiveRecord::Base
  belongs_to :wat
  belongs_to :grouping

  validates :wat, presence: true
  validates :grouping, presence: true

  before_create :set_state


  state_machine :state, initial: :active do
    state :active, :resolved, :wontfix

    event :activate do
      transition [:resolved, :wontfix] => :active
    end

    event :resolve do
      transition [:wontfix, :active] => :resolved
    end

    event :wontfix do
      transition :active => :wontfix
    end
  end

  scope :open,          -> {where(state: [:wontfix, :active])}
  scope :active,        -> {where(state: :active)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :wontfix,       -> {where(state: :wontfix)}


  def set_state
    self.state = grouping.state
  end

  def destroy
    super
    grouping.destroy if grouping.reload.wats.empty?
  end
end
