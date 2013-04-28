module SessionSpecHelper
  def login(user)
    session[:watcher_id] = user.to_param
  end

  def auth_path
    "/auth/gplus"
  end
end
