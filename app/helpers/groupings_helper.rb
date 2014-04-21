module GroupingsHelper

  def grouping_envs(grouping)
    grouping.wats.group(:app_env).pluck(:app_env).map do |env|
      "#{env} (#{grouping.wats.where(:app_env => env).count})"
    end.join ", "
  end
end
