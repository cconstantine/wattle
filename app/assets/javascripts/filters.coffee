ready = ->
  $('.page_filters :checkbox').change $.debounce((-> $(@).closest('form').submit()), 1000)

$(document).ready ready
$(document).on 'page:load', ready
