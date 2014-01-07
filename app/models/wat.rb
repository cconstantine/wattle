class Wat < ActiveRecord::Base
  #before_save :clean_backtrace
  EXCLUDES = [/\/gems\//]

  has_many :wats_groupings
  has_many :groupings, through: :wats_groupings

  after_create :construct_groupings!

  after_commit :send_email, on: :create unless Rails.env.test?
  after_create :send_email              if     Rails.env.test?

  scope :filtered, ->(opts={}) {
    running_scope = all
    running_scope = running_scope.joins(:groupings).where("groupings.state" => opts[:state]) if opts[:state]
    running_scope = running_scope.where(:app_name => opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.where(:app_env  => opts[:app_env])  if opts[:app_env]
    running_scope = running_scope.where(:language => opts[:language]) if opts[:language]
    running_scope
  }

  scope :open,          -> {joins(:groupings).where("groupings.state" => [:acknowledged, :active]) }
  scope :active,        -> {joins(:groupings).where("groupings.state" => :active)}
  scope :resolved,      -> {joins(:groupings).where("groupings.state" => :resolved)}
  scope :acknowledged,  -> {joins(:groupings).where("groupings.state" => :acknowledged)}

  scope :after, -> (start_time) {where('wats.created_at > ?', start_time)}
  scope :javascript, -> {where(language: :javascript)}
  scope :ruby,       -> {where(language: :ruby)}

  scope :distinct_users, -> {select('distinct app_user -> \'id\'')}

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

  def key_line
    return nil unless backtrace.present?
    backtrace.detect do |line|
      !EXCLUDES.any? {|e| e.match(line) }
    end
  end

  def matching_selector
    case language
      when "javascript"
        { message: message }
      else
        {
          error_class: error_class,
          key_line: (key_line || backtrace.try(:first) || "").sub(/releases\/\d+\//, '')
        }
    end
  end

  def user_agent
    return Agent.new(request_headers["HTTP_USER_AGENT"]) if request_headers.present? && request_headers["HTTP_USER_AGENT"]
  end

  def construct_groupings!
    self.groupings = (Grouping.matching(self) << Grouping.get_or_create_from_wat!(self)).uniq
  end

  def send_email
    groupings.active.pluck(:id).each do |grouping_id|
      GroupingNotifier.delay.notify(grouping_id)
    end
  end
end
