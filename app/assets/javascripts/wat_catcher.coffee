#Send the error to the same host that served this file (I think)
window.onerror = (msg,url,line) ->
  xmlhttp = if window.XMLHttpRequest
      new XMLHttpRequest()
  else
      new ActiveXObject("Microsoft.XMLHTTP")

  params =  "wat[page_url]=#{escape(window.location.toString())}"
  params += "&wat[message]=#{escape(msg)}"
  params += "&wat[backtrace][]=#{escape(url+":"+line)}"

  xmlhttp.open("POST", "/wats", true);
  xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xmlhttp.send(params);
  return false;