class WatchersController < ApplicationController
  respond_to :html

  before_filter :load_watchers, only: :index
  before_filter :load_watcher, only: [:show, :reactivate, :deactivate]

  def index

  end

  def show

  end

  def reactivate
   @watcher.activate!
   redirect_to request.referer
  end

  def deactivate
    @watcher.deactivate!
    redirect_to request.referer
  end


  protected

  def load_watchers
    @watchers = Watcher.all
  end

  def load_watcher
    @watcher = Watcher.find(params.require(:id))
  end
end
