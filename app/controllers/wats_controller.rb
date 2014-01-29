class WatsController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token, :require_login, only: [:create, :options]

  before_filter :load_context

  def index
    @wats = @context.includes(:groupings).order('id desc').page(params[:page]).per(params[:per_page] || 20)
    respond_with(@wats)
  end

  def show
    @wat = @context.find(params.require(:id))
    respond_with(@wat)
  end

  def create
    wat_params = params.require(:wat).permit!
    wat_params.delete(:id)
    wat_params.delete(:created_at)
    wat_params.delete(:updated_at)

    @wat = Wat.create!(wat_params)
  rescue ActiveRecord::RecordInvalid
  ensure
    response.headers['Content-Type'] = "image/png; charset=utf-8"
    head :ok
  end

  protected
  def load_context
    @grouping = Grouping.find(params.require(:grouping_id)) if params[:grouping_id].present?
    @context  = @grouping || Wat
  end
end
