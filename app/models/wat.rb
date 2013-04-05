class Wat < ActiveRecord::Base
  #before_save :clean_backtrace
  EXCLUDES = [/\.rvm\/gems/]

  has_many :wats_groupings
  has_many :groupings, through: :wats_groupings

  after_save :construct_groupings!

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

  def construct_groupings!
    self.groupings << Grouping.get_or_create_from_wat!(self)
  end

end
