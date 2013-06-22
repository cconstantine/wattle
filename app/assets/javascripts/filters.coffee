ready = ->
  $('.filter :checkbox').change(-> $(@).closest('form').submit())

$(document).ready ready
$(document).on 'page:load', ready