module WatsHelper
  def wat_heading(wat)
    return (wat.message || "Unknown" ) unless wat.error_class
    wat.error_class.gsub("::", ":: ")
  end

  def app_envs
    Wat.app_envs
  end

  def app_names
    Wat.app_names
  end

  def languages
    Wat.languages
  end

  def app_hosts
    Wat.app_hosts
  end
end
