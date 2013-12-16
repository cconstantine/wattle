$ ->
  $(".highchart").each ->
    console.log $(@).data().chart
    $(@).highcharts($(@).data().chart);
