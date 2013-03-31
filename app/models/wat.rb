class Wat < ActiveRecord::Base
  #before_save :clean_backtrace
  EXCLUDES = [/\.rvm\/gems/]

  belongs_to :grouping
  validates :grouping, presence: :true

  before_validation :ensure_grouping

  def self.new_from_exception(e)
    new(message: e.message, error_class: e.class.to_s, backtrace: e.backtrace)
  end

  def self.create_from_exception!(e)
    new_from_exception(e).tap {|w| w.save!}

  end

  def key_line
    return nil unless backtrace.present?
    backtrace.detect do |line|
      !EXCLUDES.any? {|e| e.match(line) }
    end
  end

  protected

  def ensure_grouping
    self.grouping = Grouping.get_or_create_from_wat!(self)
  end

  def clean_backtrace
    if backtrace_changed? && backtrace.present?
      self.backtrace = backtrace.map {|x| x.to_s.gsub(/(:\d+).*/, '\1').gsub("'", "*") }
    end
  end
end
