class Grouping < ActiveRecord::Base
  has_paper_trail class_name: "GroupingVersion", :only => [:state]

  has_many :wats_groupings
  has_many :open_wats_groupings, -> {self.open }, class_name: "WatsGrouping"
  has_many :wats, through: :open_wats_groupings
  has_many :all_wats, through: :wats_groupings
  has_many :new_wats, ->(grouping) { grouping.last_emailed_at.present? ? where('wats.created_at > ?', grouping.last_emailed_at) : self }, class_name: "Wat", through: :wats_groupings, source: :wat
  has_many :notes
  has_many :stream_events
  has_many :grouping_unsubscribes, dependent: :destroy
  has_many :unsubscribes, through: :grouping_unsubscribes, source: :watcher

  has_many :grouping_owners, dependent: :destroy
  has_many :owners, through: :grouping_owners, source: :watcher

  state_machine :state, initial: :unacknowledged do
    state :unacknowledged, :resolved, :deprioritized, :acknowledged

    event :resolve do
      transition [:deprioritized, :unacknowledged, :acknowledged] => :resolved
    end

    event :deprioritize do
      transition [:unacknowledged, :acknowledged] => :deprioritized
    end

    event :acknowledge do
      transition [:deprioritized, :unacknowledged, :resolved] => :acknowledged
    end

    after_transition any => any, :do => :reindex
  end

  scope :open,          -> {where.not(state: :resolved)}
  scope :unacknowledged,        -> {where(state: :unacknowledged)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :deprioritized,  -> {where(state: :deprioritized)}
  scope :state,         -> (state) {where(state: state)}
  scope :matching, ->(wat) {language_non_distinct(wat.language).where(wat.matching_selector).recursive_distinct('groupings.id')}
  scope :filtered, ->(opts=nil) {
    opts ||= {}

    running_scope = self
    running_scope = running_scope.app_name_non_distinct(opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.app_env_non_distinct(opts[:app_env])   if opts[:app_env]
    running_scope = running_scope.language_non_distinct(opts[:language]) if opts[:language]
    running_scope = running_scope.by_user_non_distinct(opts[:app_user])  if opts[:app_user]
    running_scope = running_scope.by_host_non_distinct(opts[:hostname])  if opts[:hostname]

    running_scope.recursive_distinct('groupings.id')
  }

  scope( :wat_order, -> { reorder("latest_wat_at asc") } ) do
    def reverse
      reorder("latest_wat_at desc")
    end
  end

  scope :app_env_non_distinct,  -> (ae) { joins(:wats).references(:wats).where('wats.app_env IN (?)', ae) }
  scope :app_name_non_distinct, -> (an) { joins(:wats).references(:wats).where('wats.app_name IN (?)', an) }
  scope :language_non_distinct, -> (an) { joins(:wats).references(:wats).where('wats.language IN (?)', an) }
  scope :by_user_non_distinct,  -> (user_id) { joins(:wats).references(:wats).where('wats.app_user -> \'id\' = ?', user_id) }
  scope :by_host_non_distinct,  -> (host) { joins(:wats).references(:wats).where('wats.hostname IN (?)', host) }

  scope :app_env,  -> (ae) { app_env_non_distinct(ae).recursive_distinct('groupings.id') }
  scope :app_name, -> (an) { app_name_non_distinct(an).recursive_distinct('groupings.id') }
  scope :language, -> (an) { language_non_distinct(an).recursive_distinct('groupings.id') }
  scope :by_user,  -> (user_id) { by_user_non_distinct(user_id).recursive_distinct('groupings.id') }

  searchkick(callbacks: false, text_middle: [:key_line, :user_emails], index_name: "#{Rails.application.class.parent_name.downcase}_#{model_name.plural}_#{Rails.env.to_s}")

  def search_data
    return {} unless wats.any?
    {
      key_line: key_line,
      error_class: error_class,
      state: state,
      message: wats.group(:message).count.keys.map {|m| (m||"").slice(0, 32765)},
      app_name: wats.first.app_name,
      app_env: wats.group(:app_env).count.keys,
      hostname: wats.group(:hostname).count.keys,
      language: wats.first.language,
      user_emails: app_user_stats(filters: {}, key_name: :email,  limit: 1000).keys,
      latest_wat_at: latest_wat_at
    }
  end

  def self.filtered_by_params(filters, opts={})
    search_query = filters[:search_query]
    search_query = "*" if search_query.blank?

    wheres = {state: opts[:state]}
    wheres[:app_env] = filters[:app_env] if filters[:app_env]
    wheres[:app_name] = filters[:app_name] if filters[:app_name]
    wheres[:language] = filters[:language] if filters[:language]

    Grouping.search(search_query, fields: [{key_line: :text_middle}, :error_class, :message, :user_emails], where: wheres, page: opts[:page], per_page: 20, order: {latest_wat_at: :desc})
  end

  def open?
    deprioritized? || unacknowledged? || acknowledged?
  end

  def app_envs(filters={})
    wats.filtered(filters).select(:app_env).uniq.map &:app_env
  end

  def languages
    wats.select(:language).uniq.map &:language
  end

  def is_javascript?
    wats.javascript.any?
  end

  def unsubscribed?(watcher)
    grouping_unsubscribes.where(watcher: watcher).any?
  end

  def app_user_stats(filters: {}, key_name: :id, limit: nil)
    wats.filtered(filters)
      .group("app_user -> '#{key_name}'")
      .order("count(app_user -> '#{key_name}') desc")
      .limit(limit).count
  end

  def app_user_count(filters: {}, key_name: :id)
    wats.filtered(filters).distinct_users.count
  end

  def browser_stats(filters: {}, key_name: :HTTP_USER_AGENT, limit: nil)
    wats.filtered(filters)
    .group("request_headers -> '#{key_name}'")
    .order("count(request_headers -> '#{key_name}') desc")
    .limit(limit).count
  end

  def browser_agent_stats(filters: {}, key_name: :HTTP_USER_AGENT, limit: nil)
    agents = Hash.new {0}
    browser_stats(filters: filters, key_name: key_name, limit: limit).each do |browser, count|
      agent = Agent.new(browser || "Unknown")
      browser = "#{agent.name} #{agent.version}" if agent.name != :Unknown
      agents[browser] += count
    end
    agents.sort_by {|k, v| -v}
  end

  def browser_count(filters: {}, key_name: :HTTP_USER_AGENT)
    wats.filtered(filters).distinct_browsers.count
  end

  def self.get_or_create_from_wat!(wat)
    disable_search_callbacks
    open.matching(wat).first_or_create!(wat.matching_selector.merge(state: "unacknowledged", uniqueness_string: wat.uniqueness_string))
  ensure
    enable_search_callbacks
  end

  def chart_data(filters)
    wat_chart_data = wats.filtered(filters).group('date_trunc(\'day\',  wats.captured_at)').count.inject({}) do |doc, values|
      doc[values[0]] = values[1]
      doc
    end
    return [] if wat_chart_data.empty?
    start_time = wat_chart_data.keys.min
    end_time   = wat_chart_data.keys.max

    wat_chart_values = []
    while start_time <= end_time
      wat_chart_values << [start_time.to_i*1000, wat_chart_data[start_time] || 0]

      start_time = start_time.advance(days: 1)
    end
    wat_chart_values
  end

  def email_recipients
    potential_watchers = owners.any? ? self.owners : Watcher.active
    potential_watchers.map do |watcher|
      next if self.unsubscribed?(watcher)
      next unless Grouping.where(id: self.to_param).filtered(watcher.email_filters).any?
      watcher
    end.compact
  end

  def self.epoch
    Wat.order(:id).first.created_at || Date.new(2015, 10, 1).to_time
  end

  def self.rescore
    Grouping.find_each do |grouping|
      grouping.rescore!
    end
  end

  def update_sorting(effective_time=nil)
    self.latest_wat_at = effective_time
  end
end
