$ ->
  $(".highchart").each ->
    $elem = $(@)
    if chart_data = $elem.data("chart")
      $elem.highcharts(chart_data);
    else if url = $elem.data("url")
      $.ajax(url).success (data) ->
        $elem.highcharts(data)
