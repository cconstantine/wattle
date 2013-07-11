class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: :index

  def index
    p params
    @groupings = Grouping.
        filtered(filters).
        wat_order.reverse

    respond_with(@groupings)
  end

  def show
    @wats = wats(@grouping)
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

  def wats(grouping)
    grouping.wats.filtered(filters)
  end
  helper_method :wats

  protected
  def filters
    params[:filters].present? ? params.require("filters").permit! : {}
  end
end
