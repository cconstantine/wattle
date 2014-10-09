class WatIgnores < ActiveRecord::Base

  def self.matches?(wat)
    where(user_agent: wat.request_headers["HTTP_USER_AGENT"]).any? if wat.request_headers.present?
  end
end
