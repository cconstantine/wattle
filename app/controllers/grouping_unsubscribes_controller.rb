class GroupingUnsubscribesController < ApplicationController
  respond_to :html

  before_filter :load_grouping, only: :create
  before_filter :load_grouping_unsubscribe, only: :destroy

  def create
    GroupingUnsubscribe.create!(watcher: current_user, grouping: @grouping)
    redirect_to request.referer
  end

  def destroy
    @grouping_unsubscribe.destroy!
    redirect_to request.referer
  end

  protected
  def load_grouping
    @grouping = Grouping.find(params.require(:grouping_id))
  end

  def load_grouping_unsubscribe
    @grouping_unsubscribe = GroupingUnsubscribe.find(params.require(:id))
  end
end
