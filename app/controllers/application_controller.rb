class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include WatCatcher::CatcherOfWats
  include Logviously::PayloadExtension
  include RateLimit

  rescue_from RateLimitExceeded do
    respond_to do |format|
      format.json  { render :json => ["Rate Limit Exceeded"], status: 429 }
      format.any   { render :text => "Rate Limit Exceeded", status: 429 }
    end
  end

  DEFAULT_FILTERS = { }.with_indifferent_access

  around_filter :query_timeouts

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
    WatConfig.secret_value('GOOGLE_KEY') || Secret.to_h.has_key?(:google_key)
  end

  def require_login
    unless current_user
      session[:redirect_to] = request.fullpath
      redirect_to auth_path
    end
  end

  def current_user
    @current_watcher ||= web_user || api_user
  end

  def web_user
    Watcher.where(id: session[:watcher_id]).first
  end

  def api_user
    Watcher.where(api_key: params[:api_key]).first if params[:api_key]
  end
  helper_method :current_user


  def query_timeouts
    ActiveRecord::Base.with_timeout(60.seconds) do
      yield
    end
  end
end
