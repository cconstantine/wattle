module WatsHelper
  def wat_heading(wat)
    return wat.message unless wat.error_class
    wat.error_class.gsub("::", ":: ") 
  end

  def top_wats
    Grouping.open.order("wats_count desc").limit(3)
  end

  def app_envs
    Grouping.select(:app_env).uniq.load.map &:app_env
  end
end
