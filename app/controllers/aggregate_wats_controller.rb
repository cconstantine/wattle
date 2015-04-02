class AggregateWatsController < ApplicationController
  ALLOWED_SCALES= %w[ day hour month week ]
  respond_to :json

  def periodic
    raise "Timescale not allowed: #{params[:scale]}" unless ALLOWED_SCALES.include?(params[:scale])
    respond_with count_by_timescale(params[:scale])
  end

  private

  def count_by_timescale(timescale)
    date_segment = Wat.send(:sanitize_conditions,["date_trunc(?, created_at)",timescale])
    grouped_query = Wat.group(date_segment)
    grouped_query.order('2 desc').count #order by the time column(2nd), since we cant predict the aggregate alias assigned by ActiveRecord
  end
end
