define ["ajax", "list_mixin"], (ajax, list_mixin) ->

  flight.component ->

    flight.compose.mixin @, [list_mixin]

    @refresh = ->
      ajax @$node, "/newest", (html) ->
        $("#newest").replaceWith html

    @defaultAttrs
      bookmark: ".bookmark"

    @init_triggers = ->
      @on "filter", @filter
      @on "refresh", @refresh

    @after "initialize", ->
      @init_triggers()

      @$node.find(".tags").find("a").click (e) =>
        @trigger "#searchbar", "search", text: $(e.target).text()
