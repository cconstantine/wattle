class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include WatCatcher::CatcherOfWats
  DEFAULT_FILTERS = {state: ['active', 'muffled']}.with_indifferent_access

  protect_from_forgery with: :exception
  before_filter :require_login

  def filters
    @_filters ||= FilterSet.new(params: params, filters: current_user.default_filters, default_filters: DEFAULT_FILTERS)
  end
  helper_method :filters

  protected

  def use_developer_auth?
    !google_auth_enabled?
  end

  def auth_path
    return "/auth/developer" if use_developer_auth?
    "/auth/gplus"
  end

  def google_auth_enabled?
    ENV['GOOGLE_KEY'] || Secret.to_h.has_key?(:google_key)
  end

  def require_login
    unless current_user
      session[:redirect_to] = request.fullpath
      redirect_to auth_path
    end
  end

  def current_user
    @current_watcher ||= Watcher.where(id: session[:watcher_id]).first
  end
  helper_method :current_user

end
