class StatsController < ApplicationController
  respond_to :html, :json

  def smoothing(data)
    new_data = []
    data.each_with_index do |entry, i|

      values = [ ]
      (-3..3).each do |offset|
        values << data[i + offset][1] if i + offset >= 0 && i + offset < data.count
      end

      real_values = []
      window_shape = [0.25, 0.5, 0.75, 1.0, 0.75, 0.5, 0.25]
      values.each_with_index do |value, i|
        real_values << value * window_shape[i]
      end
      value = real_values.count > 0 ? real_values.sum / real_values.count : 0
      new_data << [entry[0], value]
    end
    new_data
  end

  def index
    ago = (params[:months] || "1").to_i
    step = 1.day
    current_date = ago.months.ago.beginning_of_day
    end_date   = Time.zone.now.beginning_of_day

    avg_per_grouping = []
    while current_date <= end_date
      counting = Wat.filtered(filters).select('distinct grouping_id').where("captured_at between ? AND ?", current_date, current_date + step).count

      avg_per_grouping << [current_date.to_i*1000,
                           counting]
      current_date += step
    end

    @unacknowledged_groupings = {
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
                 name: 'Groupings',
                 data: avg_per_grouping
               }, {
                 name: 'Groupings (smoothed)',
                 data: smoothing(avg_per_grouping)
               }]
    }


    step = 1.day
    current_date = ago.months.ago.beginning_of_day
    # end_date   = Wat.order(:captured_at).last.captured_at.beginning_of_day

    user_wats = []
    while current_date <= end_date
      counting = Wat.filtered(filters).where("wats.captured_at between ? AND ?", current_date, current_date + step).count

      user_wats << [current_date.to_i*1000,
                    counting]
      current_date += step
    end



    @wats_counts = {
      title: {
        text: 'Daily Stats',
      },
      xAxis: {
        type: 'datetime'
      },
      yAxis: {
        type: 'logarithmic',
      },
      chart: {
        type: 'spline',
        zoomType: 'xy'
      },
      series: [{
                 name: 'Wats',
                 data: user_wats
               }, {
                 name: 'Wats (smoothed)',
                 data: smoothing(user_wats)
               }]
    }


    respond_with(@wats_counts)
  end
end
