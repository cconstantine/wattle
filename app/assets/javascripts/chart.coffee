$ ->
  $(".highchart").each ->
    $elem = $(@)
    console.log 'found a thing'
    if chart_data = $elem.data("chart")
      console.log chart_data
      $elem.highcharts(chart_data);
    else if url = $elem.data("url")
      console.log url
      $.ajax(url).success (data) ->
        console.log 'success!', data
        $elem.highcharts(data)
