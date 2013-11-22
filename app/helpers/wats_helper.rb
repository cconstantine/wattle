module WatsHelper
  def wat_heading(wat)
    return (wat.message || "Unknown" )unless wat.error_class
    wat.error_class.gsub("::", ":: ")
  end

  def app_envs
    Wat.all.uniq.pluck(:app_env)
  end

  def app_names
    Wat.all.uniq.pluck(:app_name)
  end

  def languages
    Wat.where('language is not null').uniq.pluck(:language)
  end
end
