class Wat < ActiveRecord::Base
  #before_save :clean_backtrace
  EXCLUDES = [/\.rvm\/gems/]

  has_many :wats_groupings
  has_many :groupings, through: :wats_groupings

  after_create :construct_groupings!, :send_emails

  scope :filtered, ->(opts={}) {
    Rails.logger.debug "===== opts: #{opts}"
    running_scope = Wat.all
    running_scope = running_scope.joins(:groupings).where("groupings.state = ?", opts[:state]) if opts[:state]
    running_scope = running_scope.where(:app_name => opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.where(:app_env  => opts[:app_env])  if opts[:app_env]
    running_scope
  }

  def self.new_from_exception(e=nil, metadata={}, &block)
    if block_given?
      begin
        yield
      rescue
        e = $!
      end
    end

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

  def construct_groupings!
    self.groupings = [Grouping.get_or_create_from_wat!(self)]
  end

  def send_emails
    WatMailer.delay.create(self) unless groupings.acknowledged.any?
  end
end
