define ["ajax", "list_mixin"], (ajax, list_mixin) ->

  flight.component ->

    flight.compose.mixin @, [list_mixin]

    @refresh = ->
      ajax @$node, "/newest", (html) =>
        $("#newest").replaceWith html
        @initDecoration()

    @initDecoration = ->
      lis = $("#newest li")
      lis.each (_, li) =>
        $li = $(li)
        $li.hover (=>
          $li.addClass "selected"
        ), (=>
          $li.removeClass "selected"
        )

    @defaultAttrs
      bookmark: ".bookmark"

    @init_triggers = ->
      @on "filter", @filter
      @on "refresh", @refresh

    @after "initialize", ->
      @init_triggers()

      @initDecoration()
      @$node.find(".tags").find("a").click (e) =>
        @trigger "#searchbar", "search", text: $(e.target).text()
