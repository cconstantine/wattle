class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: :index

  def index
    @groupings = Grouping.wat_order.reverse
    if params[:state].present?
      @groupings = @groupings.where(state: params[:state])
    else
      @groupings = @groupings.open
    end
    if params[:app_env].present?
      @groupings = @groupings.app_env(params[:app_env])
    end

    respond_with(@groupings)
  end

  def show
    respond_with(@grouping)
  end

  def resolve
    @grouping.resolve!
    redirect_to request.referer
  end

  def activate
    @grouping.activate!
    redirect_to request.referer
  end

  def acknowledge
    @grouping.acknowledge!
    redirect_to request.referer
  end

  def load_group
    @grouping = Grouping.find(params.require(:id))
  end
end
