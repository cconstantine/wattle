module ApplicationHelper

  def checked? param, key
    return false unless has_filter?(param)
    params[:filters][param].include?(key)
  end

  def has_filter? param
    return false unless params[:filters].present?
    params[:filters][param].present?
  end

  def wats(grouping)
    filtered = grouping.wats.filtered(filters)
    filtered
  end

  def markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(link_attributes: {target: :_blank}),
                            autolink: true,
                            tables: true,
                            no_intra_emphasis: true,
                            lax_spacing: true,
                            fenced_code_blocks: true,
                            superscript: true,
                            footnotes: true
    ).render(text).html_safe
  end

end
