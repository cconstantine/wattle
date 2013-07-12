module ApplicationHelper

  def checked? param, key
    return false unless params[:filters].present?
    params[:filters][param].present? && params[:filters][param].include?(key)
  end

  def wats(grouping)
    Rails.logger.debug "===== Helper grouping wats: #{grouping.wats.map(&:app_env)}"

    filtered = grouping.wats.filtered(filters)
    Rails.logger.debug "===== Helper wats: #{filtered.all}"
    filtered
  end

end
