module WatsHelper
  def wat_heading(wat)
    wat.error_class || wat.message
  end

  def top_wats
    Grouping.order("wats_count desc").limit(3)
  end
end
