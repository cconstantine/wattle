class AggregateWatsController < ApplicationController
  ALLOWED_SCALES= %w[ day hour month week ]
  respond_to :json

  def periodic
    raise "Timescale not allowed: #{params[:scale]}" unless ALLOWED_SCALES.include?(params[:scale])
    counter = WatCounter.new params[:scale]
    @wats = counter.group(:app_env, :language, :app_name).page(params[:page]).per(params[:per_page] || 1000)
    respond_with counter.format(@wats)
  end
end
