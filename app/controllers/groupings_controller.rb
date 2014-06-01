class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: [:index, :create, :new]

  def index
    @groupings = Grouping.filtered(filters)
    @order = params[:order].try(:to_sym) || :new
    if @order == :new
      @groupings = @groupings.wat_order.reverse
    else
      @groupings = @groupings.order('popularity desc')
    end

    @groupings = @groupings.page(params[:page]).per(params[:per_page] || 20)

    respond_with(@groupings)
  end

  def show
    wat_chart_values = @grouping.chart_data(filters)

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

  def create
    grouping_ids = params[:grouping_ids].split(',')
    groupings = Grouping.find(grouping_ids)
    new_grouping = Grouping.merge! groupings
    redirect_to new_grouping
  end

  def new
  end

  def resolve
    @grouping.resolve!
    redirect_to request.referer
  end

  def activate
    @grouping.activate!
    redirect_to request.referer
  end

  def wontfix
    @grouping.wontfix!
    redirect_to request.referer
  end

  def muffle
    @grouping.muffle!
    redirect_to request.referer
  end

  def destroy
    if @grouping.subgroupings.any? && @grouping.destroy!
      redirect_to groupings_path
    else
      redirect_to(@grouping, alert: "Please only delete manually merged groupings")
    end
  end

  private

  def load_group
    @grouping = Grouping.find(params.require(:id))
  end

end
