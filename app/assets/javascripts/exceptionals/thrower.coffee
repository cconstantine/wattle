this.thrower = (msg) ->
  throw new Error(msg)


setTimeout ->
  thrower("foo")
, 1000