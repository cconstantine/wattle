class GroupingsController < ApplicationController
  respond_to :html, :json

  def index
    @groupings = Grouping.all

    respond_with(@grouping)
  end

  def show
    @grouping = Grouping.find(params.require(:id))
    respond_with(@grouping)
  end
end
