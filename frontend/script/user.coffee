require.config
  baseUrl: "/js/rjs"

require ["ajax", "token", "selection"], (ajax, Token, Selection) ->

  $(".status").hide()

  Token.attachTo $("#tokens .token")

  $("#addtoken").click ->
    ajax $(@), "/tokens/new", (html) ->
      $("#tokens").append html
      Token.attachTo $("#tokens .token").last()

  Selection.setup $("#addtoken")
