class GroupingsController < ApplicationController
  respond_to :html

  before_filter :load_group, except: :index
  before_filter :load_chart_data, only: :show

  def index
    @active_tab = params[:state] || "unacknowledged"
    @groupings = Grouping.filtered_by_params(filters, page: params[:page], state: params[:state])

    respond_with(@groupings)
  end

  def show
    @stream_events = @grouping.stream_events.order(:happened_at)
    @wats = @grouping.wats.filtered(filters)

    @tracker_api = current_user.tracker
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

  def load_chart_data
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
                     data: @grouping.chart_data(filters)
                 }]
    }
  rescue ActiveRecord::StatementInvalid

  end

end
