ready = ->
  $('.filter :checkbox').change ->
    $(".edit_watcher input").attr("disabled", "disabled");
    $.debounce((-> $(@).closest('form').submit()), 1000).call(this, arguments...)

$(document).ready ready
$(document).on 'page:load', ready
