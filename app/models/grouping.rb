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

  state_machine :state, initial: :active do
    state :active, :resolved, :wontfix, :muffled

    event :activate do
      transition [:resolved, :wontfix, :muffled] => :active
    end

    event :resolve do
      transition [:wontfix, :active, :muffled] => :resolved
    end

    event :wontfix do
      transition [:active, :muffled] => :wontfix
    end

    event :muffle do
      transition [:wontfix, :active] => :muffled
    end
  end

  scope :open,          -> {where.not(state: :resolved)}
  scope :active,        -> {where(state: :active)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :wontfix,  -> {where(state: :wontfix)}
  scope :state,         -> (state) {where(state: state)}
  scope :matching, ->(wat) {language_non_distinct(wat.language).where(wat.matching_selector).recursive_distinct('groupings.id')}
  scope :filtered, ->(opts=nil) {
    opts ||= {}

    running_scope = self
    running_scope = running_scope.state(opts[:state])       if opts[:state]
    running_scope = running_scope.app_name_non_distinct(opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.app_env_non_distinct(opts[:app_env])   if opts[:app_env]
    running_scope = running_scope.language_non_distinct(opts[:language]) if opts[:language]
    running_scope = running_scope.by_user(opts[:app_user])  if opts[:app_user]

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

  scope :app_env,  -> (ae) { app_env_non_distinct(ae).recursive_distinct('groupings.id') }
  scope :app_name, -> (an) { app_name_non_distinct(an).recursive_distinct('groupings.id') }
  scope :language, -> (an) { language_non_distinct(an).recursive_distinct('groupings.id') }
  scope :by_user,  -> (user_id) { by_user_non_distinct(user_id).recursive_distinct('groupings.id') }

  searchkick(text_middle: [:key_line, :user_emails], index_name: "#{Rails.application.class.parent_name.downcase}_#{model_name.plural}_#{Rails.env.to_s}")

  def search_data
    {
      key_line: key_line,
      error_class: error_class,
      state: state,
      message: wats.group(:message).count.keys,
      app_name: wats.group(:app_name).count.first.first,
      app_env: wats.group(:app_env).count.keys,
      language: wats.group(:language).count.first.first,
      user_emails: app_user_stats(filters: {}, key_name: :email,  limit: 1000).keys#  wats.limit(100).pluck('distinct wats.app_user -> \'email\'').join(' ')
    }
  end

  def self.filtered_by_params(filters, opts={})
    search_query = filters[:search_query]

    unless search_query.blank?
      # raise search_query.inspect

      wheres = {}
      wheres[:state] = filters[:state] if filters[:state]
      wheres[:app_env] = filters[:app_env] if filters[:app_env]
      wheres[:app_name] = filters[:app_name] if filters[:app_name]
      wheres[:language] = filters[:language] if filters[:language]

      @groupings = Grouping.search(search_query, fields: [{key_line: :text_middle}, :error_class, :message, :user_emails], where: wheres, page: opts[:page], per_page: 20)
    else
      @groupings = Grouping.filtered(filters)
      @groupings = @groupings.wat_order.reverse
      @groupings = @groupings.page(opts[:page]).per(20)
    end
  end

  def open?
    wontfix? || active? || muffled?
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
    transaction do
      open.matching(wat).first_or_create!(wat.matching_selector.merge(state: "active", uniqueness_string: wat.uniqueness_string))
    end
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

  def rescore!
    transaction do
      self.wats.where("wats_groupings.state != ?", :resolved).find_each do |wat|
        self.upvote wat.created_at
      end
      self.save!
    end
  end

  def update_sorting(effective_time=nil)
    self.latest_wat_at = effective_time
  end
end
