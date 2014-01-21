class Grouping < ActiveRecord::Base
  has_many :wats_groupings
  has_many :new_wats, ->(grouping) { grouping.last_emailed_at.present? ? where('wats.created_at > ?', grouping.last_emailed_at) : self }, class_name: "Wat", through: :wats_groupings, source: :wat
  has_many :wats, through: :wats_groupings
  has_many :notes

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

  scope :open,          -> {distinct('groupings.id').where(state: [:acknowledged, :active])}
  scope :active,        -> {distinct('groupings.id').where(state: :active)}
  scope :resolved,      -> {distinct('groupings.id').where(state: :resolved)}
  scope :acknowledged,  -> {distinct('groupings.id').where(state: :acknowledged)}
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

  def app_user_stats(key_name: :id, limit: nil)
    wats
      .select("app_user -> '#{key_name}' as #{key_name}, count(*) as count")
      .group("app_user -> '#{key_name}'")
      .order('wats.count desc')
      .limit(limit).count
  end

  def app_user_count(key_name: :id)
    wats.distinct_users.count
  end

  def self.get_or_create_from_wat!(wat)
    transaction do
      open.matching(wat).first_or_create(state: "active")
    end
  end

  def chart_data
    wat_chart_data = wats.group('date_trunc(\'day\',  wats.created_at)').count.inject({}) do |doc, values|
      doc[values[0]] = values[1]
      doc
    end
    start_time = wat_chart_data.keys.min
    end_time   = wat_chart_data.keys.max

    wat_chart_values = []
    while start_time <= end_time
      wat_chart_values << [start_time.to_i*1000, wat_chart_data[start_time] || 0]

      start_time = start_time.advance(days: 1)
    end
    wat_chart_values
  end

  def self.epoch
    Wat.order(:id).first.created_at || Date.new(2015, 10, 1).to_time
  end

  def self.rescore
    Grouping.find_each do |grouping|
      grouping.rescore!
    end
  end

  def rescore!
    transaction do
      self.popularity = nil
      self.wats.where("wats_groupings.state != ?", :resolved).find_each do |wat|
        self.upvote wat.created_at
      end
      self.save!
    end
  end

  def upvote(effective_time=nil)
    effective_time = Time.zone.now unless effective_time
    self.popularity = 0.1 unless self.popularity

    self.popularity += 0.1 * (2 ** ((effective_time.to_i - Grouping.epoch.to_i) / 1.day.to_i))
  end
end
