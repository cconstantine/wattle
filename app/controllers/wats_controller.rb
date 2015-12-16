class WatsController < ApplicationController
  respond_to :html, :json

  class CreateWatWorker
    include Sidekiq::Worker
    sidekiq_options queue: :high

    def perform(params)
      params = YAML.load(params)
      wat_params = params.require(:wat).permit!
      wat_params.delete(:id)
      wat_params.delete(:created_at)
      wat_params.delete(:updated_at)

      @wat = Wat.create!(wat_params)
    rescue ActiveRecord::RecordInvalid
    end
  end

  skip_before_filter :verify_authenticity_token, :require_login, only: [:create, :options]

  def index
    @wats = Wat.includes(:grouping).order('id desc').page(params[:page]).per(params[:per_page] || 20)
    respond_with(@wats)
  end

  def show
    @wat = Wat.find(params.require(:id))
    respond_with(@wat)
  end

  def create
    CreateWatWorker.perform_async(params.to_yaml)
    response.headers['Content-Type'] = "image/png; charset=utf-8"
    head :ok
  end
end
