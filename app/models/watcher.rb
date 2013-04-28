class Watcher < ActiveRecord::Base
  class << self
    def find_or_create_from_auth_hash(auth_hash)
      where(email: auth_hash[:email]).first_or_create(auth_hash.slice(:first_name, :name))
    end
  end

  def display_name
    first_name
  end
end
