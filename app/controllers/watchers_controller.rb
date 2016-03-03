class WatchersController < ApplicationController
  respond_to :html

  before_filter :load_watchers, only: :index
  before_filter :load_watcher, only: [:show, :update, :reactivate, :deactivate, :reset_api_key]

  before_filter :only_update_self, only: :update

  def index

  end

  def show

  end

  def update
    attrs = filters_params(:pivotal_tracker_api_key, default_filters: {}, email_filters: {})
    @watcher.update_attributes!(attrs)
    flash[:notice] = "Your defaults were saved!"
    redirect_to :back
  end

  def reactivate
   @watcher.activate!
   redirect_to request.referer
  end

  def deactivate
    @watcher.deactivate!
    redirect_to request.referer
  end

  def reset_api_key
    @watcher.update_attributes api_key: TokenSource.new.generate
    redirect_to request.referer
  end


  protected

  def load_watchers
    @watchers = Watcher.all
  end

  def load_watcher
    @watcher = Watcher.find(params.require(:id))
  end

  def only_update_self
    redirect_to :back unless @watcher == current_user
  end

  def filters_params(*which_filters)
    params.require(:watcher).permit(*which_filters)
  end
end
