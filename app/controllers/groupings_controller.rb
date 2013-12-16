class GroupingsController < ApplicationController
  respond_to :html, :json

  before_filter :load_group, except: :index

  def index
    @groupings = Grouping.filtered(filters).wat_order.reverse.page(params[:page]).per(params[:per_page] || 20)
    @chart = {
      title: {
        text: 'Daily Stats',
      },
      xAxis: {
        type: 'datetime'
      },
      series: [{
          name: 'All Wats',
          data: Wat.group('date(created_at)').order('DATE(created_at) DESC').count.map {|k, v| [k.to_time.to_i*1000, v]}.sort {|x, y| x[0] <=> y[0]}
      },{
        name: 'Groupings',
        data: Grouping.group('date(created_at)').order('DATE(created_at) DESC').count.map {|k, v| [k.to_time.to_i*1000, v]}.sort {|x, y| x[0] <=> y[0]}
      }]
    }

    respond_with(@groupings)
  end

  def show
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
