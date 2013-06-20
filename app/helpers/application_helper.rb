module ApplicationHelper
  def javascript_wattle
     "<script>watCatcher.appEnvsToWorryAbout= [\"demo\", \"staging\", \"production\", \"development\", \"goobilygoo\"];watCatcher.appEnv= \"#{Rails.env}\"</script>".html_safe
  end
end
