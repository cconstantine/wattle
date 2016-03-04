module ApplicationHelper
  def wats(grouping)
    grouping.wats.filtered(filters)
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

  def project_select
    current_user.pivotal_tracker_projects.map do |project|
      [ project.name, project.tracker_id ]
    end
  end
end
