class GroupingsController < ApplicationController
  respond_to :html, :json

  def index
    @groupings = Grouping.wat_order.reverse

    respond_with(@groupings)
  end

  def show
    @grouping = Grouping.find(params.require(:id))
    respond_with(@grouping)
  end
end
