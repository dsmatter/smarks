define ["ajax", "selection"], (ajax, Selection) ->

  flight.component ->

    @remove = ->
      ajax @$node, "/tokens/#{@attr.id}", type: "DELETE", =>
        @$node.fadeOut().remove()
        @teardown()

    @after "initialize", ->
      @attr.id = @$node.attr("id").replace "token-", ""

      @$node.find(".delete").click =>
        @remove()

      Selection.setup @$node.find(".delete")
