class GroupingsController < ApplicationController
  respond_to :html

  before_filter :load_group, except: :index

  def index
    @groupings = Grouping.state(params[:state] || :unacknowledged).filtered_by_params(filters, page: params[:page])

    respond_with(@groupings)
  end

  def show
    wat_chart_values = @grouping.chart_data(filters)
    @stream_events = @grouping.stream_events.order(:happened_at)

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

  def deprioritize
    @grouping.deprioritize!
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
