define ["ajax", "list_mixin"], (ajax, list_mixin) ->

  flight.component ->

    flight.compose.mixin @, [list_mixin]

    @defaultAttrs
      bookmark: ".bookmark"

    @init_triggers = ->
      @on "filter", @filter

    @after "initialize", ->
      @init_triggers()

      @$node.find(".tags").find("a").click (e) =>
        @trigger "#searchbar", "search", text: $(e.target).text()
