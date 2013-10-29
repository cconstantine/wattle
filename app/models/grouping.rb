class Grouping < ActiveRecord::Base
  has_many :open_wats_groupings, -> {self.open }, class_name: "WatsGrouping"
  has_many :wats_groupings
  has_many :wats, through: :open_wats_groupings
  has_many :all_wats, through: :wats_groupings

  state_machine :state, initial: :active do
    state :active, :resolved, :acknowledged

    event :activate do
      transition [:resolved, :acknowledged] => :active
    end

    event :resolve do
      transition [:acknowledged, :active] => :resolved
    end

    event :acknowledge do
      transition :active => :acknowledged
    end
  end

  scope :open,          -> {where(state: [:acknowledged, :active])}
  scope :active,        -> {where(state: :active)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :acknowledged,  -> {where(state: :acknowledged)}
  scope :matching, ->(wat) {distinct('groupings.id').language(wat.language).where(wat.matching_selector)}
  scope :filtered, ->(opts=nil) {
    opts ||= {}
    if opts[:state]
      running_scope = where(state: opts[:state])
    else
      running_scope = open
    end
    running_scope = running_scope.app_name(opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.app_env(opts[:app_env])   if opts[:app_env]
    running_scope = running_scope.language(opts[:language]) if opts[:language]

    running_scope
  }

  scope( :wat_order, -> { joins(:wats).group(:"groupings.id").reorder("max(wats.id) asc") } ) do
    def reverse
      reorder("max(wats.id) desc")
    end
  end

  scope :app_env,  -> (ae) { joins(:wats).references(:wats).where('wats.app_env IN (?)', ae) }
  scope :app_name, -> (an) { joins(:wats).references(:wats).where('wats.app_name IN (?)', an) }
  scope :language, -> (an) { joins(:wats).references(:wats).where('wats.language IN (?)', an) }

  def open?
    acknowledged? || active?
  end

  def app_envs
    wats.select(:app_env).uniq.map &:app_env
  end

  def is_javascript?
    wats.javascript.any?
  end

  def self.get_or_create_from_wat!(wat)
    transaction do
      open.matching(wat).first_or_create(state: "active")
    end
  end

end
