define ["ajax", "list", "selection"], (ajax, List, Selection) ->

  flight.component ->

    @refresh_list = (_, opts) ->
      list_element = @$node.find "#list-#{opts.id}"
      ajax list_element, "/list/#{opts.id}", (html) =>
        opts.html = html
        @trigger "replace_list", opts

    @replace_list = (_, opts) ->
      selector = "#list-#{opts.id}"
      @$node.find(selector).replaceWith opts.html
      List.attachTo @$node.find(selector),
        id: opts.id

    @new_list = ->
      ajax @$node, "/new_list", (html) =>
        @$node.append html
        @trigger "#sidebar", "refresh"

        id = $(html).attr("id")
        element = @$node.find "##{id}"
        List.attachTo element,
          id: id.replace "list-", ""

    @after "initialize", ->
      @on "replace_list", @replace_list
      @on "refresh_list", @refresh_list

      @$node.find(".list").each ->
        list_id = $(@).attr("id").replace "list-", ""
        List.attachTo $(@), id: list_id

      $("#addlist").click => @new_list()
      Selection.setup $("#addlist")

