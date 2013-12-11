module ApplicationHelper

  def checked? param, key
    return false unless params[:filters].present?
    params[:filters][param].present? && params[:filters][param].include?(key)
  end

  def wats(grouping)
    filtered = grouping.wats.filtered(filters)
    filtered
  end

  def markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, autolink: true, tables: true, no_intra_emphasis: true, lax_spacing: true, fenced_code_blocks: true, superscript: true, footnotes: true).render(text).html_safe
  end

end
