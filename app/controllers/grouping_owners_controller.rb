class GroupingOwnersController < ApplicationController
  respond_to :html

  before_filter :load_grouping, only: :create
  before_filter :load_grouping_owner, only: :destroy

  def create
    GroupingOwner.create!(watcher: current_user, grouping: @grouping)
    flash[:notice] = "You are now an owner of this grouping.  Other users that aren't owners won't receive emails when a new Wat comes in."
    redirect_to request.referer
  end

  def destroy
    @grouping_owner.destroy!
    redirect_to request.referer
  end

  protected
  def load_grouping
    @grouping = Grouping.find(params.require(:grouping_id))
  end

  def load_grouping_owner
    @grouping_owner = GroupingOwner.find(params.require(:id))
  end
end
