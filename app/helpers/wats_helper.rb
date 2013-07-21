module WatsHelper
  def wat_heading(wat)
    return (wat.message || "Unknown" )unless wat.error_class
    wat.error_class.gsub("::", ":: ")
  end

  def top_wats
    Grouping.open.order("wats_count desc").limit(3)
  end

  def app_envs
    Wat.select(:app_env).uniq.load.map &:app_env
  end

  def app_names
    Wat.select(:app_name).uniq.load.map &:app_name
  end
end
