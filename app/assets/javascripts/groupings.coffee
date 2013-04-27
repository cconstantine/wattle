jQuery ->
  $(document).on 'click', '.complete_backtrace', ->
    $(@).hide().prev('.backtrace_container').addClass('complete')

  $(document).on 'click', '.obscure_backtrace', ->
    $(@).closest('.backtrace_container').removeClass('complete').next('.complete_backtrace').show()
