class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login

  def filters
    params[:filters].present? ? params.require("filters").permit! : {}
  end
  helper_method :filters

  protected

  def auth_path
    return "/auth/developer" if Rails.env.development? && !google_auth_enabled?
    "/auth/gplus"
  end

  def google_auth_enabled?
    Secret.to_h.has_key?(:google_key)
  end

  def require_login
    redirect_to auth_path unless current_user
  end

  def current_user
    @current_watcher ||= Watcher.where(id: session[:watcher_id]).first
  end
  helper_method :current_user

end
