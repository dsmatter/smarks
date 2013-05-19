define ->

  setup: (element) ->
    over = ->
      $(element).addClass "selected"
    out = ->
      $(element).removeClass "selected"

    $(element).hover over, out
