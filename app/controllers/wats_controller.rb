class WatsController < ApplicationController
  respond_to :json

  before_filter :load_context

  def index
    @wats = @context.where("true")
    respond_with(@wats)
  end

  def show
    @wat = @context.find(params.require(:id))
    respond_with(@wat)
  end

  def create
    @wat = Wat.create!(params.require(:wat).permit(:message, :error_class, :backtrace))
    respond_with(@wat)
  end

  protected
  def load_context
    @grouping = Grouping.find(params.require(:grouping_id)) if params[:grouping_id].present?
    @context  = @grouping || Wat
  end
end
