class SessionsController < ApplicationController
  skip_before_filter :require_login

  def create
    @watcher = Watcher.find_or_create_from_auth_hash(auth_hash)
    session[:watcher_id] = @watcher.to_param
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env["omniauth.auth"][:info].to_h.symbolize_keys
  end
end
