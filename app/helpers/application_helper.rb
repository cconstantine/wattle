module ApplicationHelper

  def checked? param, key
    return false unless params[:filters].present?
    params[:filters][param].present? && params[:filters][param].include?(key)
  end

  def wats(grouping)
    filtered = grouping.wats.filtered(filters)
    filtered
  end

end
