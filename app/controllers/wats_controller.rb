class WatsController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token, only: :create

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
    wat_params = params.require(:wat).permit(:message, :error_class, :page_url, :session, backtrace: [])
    if wat_params[:session].blank? && session.as_json.class != Array
      wat_params[:session] = session.as_js
    end

    @wat = Wat.create!(wat_params)
    head :ok and return if request.xhr?
    respond_with(@wat)
  end

  protected
  def load_context
    @grouping = Grouping.find(params.require(:grouping_id)) if params[:grouping_id].present?
    @context  = @grouping || Wat
  end
end
