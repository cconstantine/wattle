class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: [:index, :index_chart]

  def index
    @groupings = Grouping.filtered(filters).wat_order.reverse.page(params[:page]).per(params[:per_page] || 20)
    #
    #step = 1.day
    #current_date = 3.months.ago
    #end_date   = Wat.order(:id).last.created_at.beginning_of_day
    #
    #rubies = []
    #graph_filters = filters.dup
    #graph_filters["state"] = Grouping.distinct(:state).pluck(:state)
    #while current_date <= end_date
    #  rubies << [current_date.to_i*1000, Grouping.filtered(graph_filters).select('distinct groupings.id').joins(:wats).filtered(filters).where("wats.created_at between ? AND ?", current_date, current_date + step).count]
    #  current_date += step
    #end
    #
    #rubies = Grouping.joins(:wats).where('true').group('date_trunc(\'day\', groupings.created_at)').count.map do |values|
    #  [values[0].to_i*1000, values[1]]
    #end.sort! {|lhs, rhs| lhs[0] <=> rhs[0]}
    #
    #
    #@chart = {
    #  title: {
    #    text: 'Daily Stats',
    #  },
    #  xAxis: {
    #    type: 'datetime'
    #  },
    #  chart: {
    #    type: 'spline',
    #    zoomType: 'xy'
    #  },
    #  series: [{
    #             name: 'Rubies',
    #             data: rubies
    #           }]
    #}

   respond_with(@groupings)
  end

  def show

    wat_chart_values = @grouping.chart_data

    @chart = {
      title: {
        text: 'Daily Stats',
      },
      xAxis: {
        type: 'datetime'
      },
      chart: {
        type: 'spline',
        zoomType: 'xy'
      },
      series: [{
                 name: "Wats",
                 data: wat_chart_values
               }]
    }
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

end
