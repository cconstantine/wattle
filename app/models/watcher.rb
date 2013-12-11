class Watcher < ActiveRecord::Base
  EMAIL_REGEX = /@#{Regexp.escape(Secret.restrict_domain || "")}\z/

  validates :email, :format => {:with => EMAIL_REGEX }, :if => Proc.new {Secret.restrict_domain.present? }, :on => :create
  has_many :notes

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      where(email: auth_hash[:email]).first_or_create(auth_hash.slice(:first_name, :name))
    end
  end

  def display_name
    first_name || name || email
  end
end
