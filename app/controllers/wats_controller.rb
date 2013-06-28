class WatsController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token, :require_login, only: [:create, :options]

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
    wat_params = params.require(:wat).permit(:message, :error_class, :page_url, :session, :app_env, backtrace: [])
    if wat_params[:session].blank? && session.as_json.class != Array
      wat_params[:session] = session.as_json
    end

    @wat = Wat.create!(wat_params)
    response.headers['Content-Type'] = "image/png; charset=utf-8"
    head :ok
  end

  protected
  def load_context
    @grouping = Grouping.find(params.require(:grouping_id)) if params[:grouping_id].present?
    @context  = @grouping || Wat
  end
end
