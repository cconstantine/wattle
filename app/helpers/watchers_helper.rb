require 'digest/md5'
module WatchersHelper
  def gravatar_url(user)
    email_hash = Digest::MD5.hexdigest user.email.strip.downcase 
    "//www.gravatar.com/avatar/#{email_hash}?s=30"
  end
end
