module ApplicationHelper

  def checked? param, key
    params[param].present? && params[param].include?(key)
  end
end
