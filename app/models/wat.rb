class Wat < ActiveRecord::Base
  #before_save :clean_backtrace
  EXCLUDES = [/\/gems\//]

  has_many :wats_groupings, dependent: :destroy
  has_many :groupings, through: :wats_groupings

  before_save :cleanup_hstore_columns
  before_create :ensure_captured_at

  after_create :construct_groupings!

  after_commit :send_email, on: :create unless Rails.env.test?
  after_create :send_email              if     Rails.env.test?
  after_commit :reindex_groupings

  after_create :upvote_groupings

  validates :language, inclusion: { in: %w(ruby javascript) }, allow_nil: true
  validate :request_headers_not_ignored
  validate :validate_sidekiq_job_retry_count

  scope :filtered, ->(opts={}) {
    running_scope = all
    running_scope = running_scope.joins(:groupings).where("groupings.state" => opts[:state]) if opts[:state]
    running_scope = running_scope.where(:app_name => opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.where(:app_env  => opts[:app_env])  if opts[:app_env]
    running_scope = running_scope.where(:language => opts[:language]) if opts[:language]
    running_scope = running_scope.by_user(opts[:app_user])            if opts[:app_user]
    running_scope = running_scope.where(:hostname => opts[:hostname]) if opts[:hostname]

    running_scope
  }

  scope :open,          -> {joins(:groupings).where("groupings.state" => [:wontfix, :active]) }
  scope :active,        -> {joins(:groupings).where("groupings.state" => :active)}
  scope :resolved,      -> {joins(:groupings).where("groupings.state" => :resolved)}
  scope :wontfix,       -> {joins(:groupings).where("groupings.state" => :wontfix)}

  scope :after, -> (start_time) {where('wats.captured_at > ?', start_time)}
  scope :language, -> (language) {where(language: language)}
  scope :javascript, -> {language(:javascript)}
  scope :ruby,       -> {language(:ruby)}
  scope :app_name,   -> (name) {where(:app_name => name) }
  scope :app_env,   -> (name) {where(:app_env => name) }
  scope :by_user,   -> (user_id) {where('app_user -> \'id\' in (?)', user_id)}

  scope :distinct_users, -> {select('distinct app_user -> \'id\'')}
  scope :distinct_browsers, -> {select('distinct request_headers -> \'HTTP_USER_AGENT\'')}

  # See: http://zogovic.com/post/44856908222/optimizing-postgresql-query-for-distinct-values
  def self.distinct(column)
    query = <<-SQL
WITH RECURSIVE t(n) AS (  SELECT MIN(#{column}) FROM wats
UNION
  SELECT (SELECT #{column} FROM wats WHERE #{column} > n ORDER BY #{column} LIMIT 1)
  FROM t WHERE n IS NOT NULL
) SELECT n FROM t  WHERE (n is not null)
SQL
    connection.execute(query).map { |row| row["n"] }
  end

  def self.new_from_exception(e=nil, metadata={}, &block)
    if block_given?
      begin
        yield
      rescue
        e = $!
      end
    end

    metadata[:language] ||= "ruby"
    new(metadata.merge(message: e.message, error_class: e.class.to_s, backtrace: e.backtrace))
  end

  def self.create_from_exception!(e=nil, metadata={}, &block)
    new_from_exception(e, metadata, &block).tap {|w|
      w.save!
    }
  end

  def self.languages
    distinct(:language)
  end

  def self.app_names
    distinct(:app_name)
  end

  def self.app_envs
    distinct(:app_env)
  end

  def self.app_hosts
    distinct(:hostname)
  end

  def key_line
    return nil unless backtrace.present?
    backtrace.detect do |line|
      !EXCLUDES.any? {|e| e.match(line) }
    end
  end

  def key_line_clean
    (key_line || backtrace.try(:first) || "").sub(/releases\/\d+\//, '')
  end

  def matching_selector
    case language
      when "javascript"
        { message: message }
      else
        {
          error_class: error_class,
          key_line: key_line_clean
        }
    end
  end

  def uniqueness_string
    sha256 = Digest::SHA256.new
    Base64.encode64(sha256.digest(sha256.digest matching_selector.merge(language: language).to_yaml))
  end

  def user_agent
    return Agent.new(request_headers["HTTP_USER_AGENT"]) if request_headers.present? && request_headers["HTTP_USER_AGENT"]
  end

  def construct_groupings!
    self.groupings = (Grouping.matching(self) << Grouping.get_or_create_from_wat!(self)).uniq
  end

  def send_email
    groupings.active.pluck(:id).each do |grouping_id|
      GroupingNotifier.debounce_enqueue(grouping_id, GroupingNotifier::DEBOUNCE_DELAY)
    end
  end

  def reindex_groupings
    groupings.each do |grouping|
      GroupingReindexer.debounce_enqueue(grouping.id, GroupingReindexer::DEBOUNCE_DELAY)
    end
  end


  def upvote_groupings
    groupings.open.find_each do |grouping|
      grouping.update_sorting(self.created_at)
      grouping.save!
    end
  end

  def cleanup_hstore_columns
    self.app_user = clean_hstore(app_user) if app_user
    self.request_headers = clean_hstore(request_headers) if request_headers
    self.request_params = clean_hstore(request_params) if request_params
    self.session = clean_hstore(session) if session
    self.backtrace = clean_hstore(backtrace) if backtrace
  end


  def clean_hstore(values)

    if values.is_a? Array
      values.map do |elem|
        elem.respond_to?(:gsub) ? elem.gsub("\u0000", "\\u0000") : elem
      end
    else
      new_values = {}
      values.each do |key, value|
        cleaned_key = key.to_s.gsub("\u0000", "\\u0000")
        cleaned_key = cleaned_key.to_sym if key.is_a? Symbol
        if value.respond_to? :gsub
          value = value.gsub("\u0000", "\\u0000")
        end
        new_values[cleaned_key] = value
      end
      new_values
    end
  end

  def language=(lang)
    super lang.to_s.downcase
  end

  def ensure_captured_at
    self.captured_at ||= Time.zone.now
  end

  def request_headers_not_ignored
    errors.add(:request_headers) if WatIgnores.matches?(self)
  end

  def validate_sidekiq_job_retry_count
    return unless sidekiq_msg
    return unless sidekiq_msg["retry"].to_s == "true"

    errors.add(:sidekiq_msg) unless sidekiq_msg["retry_count"].to_i > 3
  end
end
