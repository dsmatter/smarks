define ["ajax", "selection"], (ajax, Selection) ->

  BookmarkEdit = flight.component ->

    @getTitle = ->
      @select("title").val()

    @getUrl = ->
      @select("url").val()

    @getList = ->
      @select("list_selection").val()

    @defaultAttrs
      title: ".title"
      url: ".url"
      list_selection: ".listselect"

    @init_events = ->
      update = =>
        @trigger "update",
          title: @getTitle()
          url: @getUrl()
          list: @getList()

      update_on_enter = (event) =>
        update() if event.which is 13

      @select("title").keyup update_on_enter
      @select("url").keyup update_on_enter
      @select("list_selection").change update

    @after "initialize", ->
      @init_events()
      @select("title").focus()


  flight.component ->

    @update = (_, opts) ->
      ajax @$node, "/bookmark/#{@attr.id}",
        type: "POST"
        data: opts
      , (html) =>
        if opts.list is @attr.list_id
          @trigger "replace_bookmark",
            id: @attr.id
            html: html
        else
          @move opts.list
        @teardown()

    @move = (list_id) ->
      list_element = $("#list-#{@attr.list_id}")
      ajax list_element, "/bookmark/#{@attr.id}/move/#{list_id}", (html) =>
        @trigger "refresh_list",
          id: list_id
        @trigger "replace_list",
          id: @attr.list_id
          html: html

    @remove = (e) ->
      ajax @$node, "/bookmark/#{@attr.id}", type: "DELETE", =>
        @trigger "update_no_bookmarks", add: -1
        @trigger "#newest", "refresh"
        @$node.fadeOut().remove()
        @teardown()

    @edit = ->
      ajax @$node, "/bookmark/#{@attr.id}", (html) =>
        @select("link").html html
        BookmarkEdit.attachTo @select "link"

    @defaultAttrs
      remove: ".delete_bookmark"
      edit: ".edit_bookmark"
      link: ".link"
      tags: ".tags"

    @init_triggers = ->
      @on "delete_bookmark", @remove
      @on "edit", @edit
      @on "update", @update

    @init_events = ->
      @select("remove").click => @trigger "delete_bookmark"
      @select("edit").click =>
        @trigger "edit" unless @select("link").find("input").length > 0
      @select("tags").find("a").click (e) =>
        @trigger "#searchbar", "search", text: $(e.target).text()

    @after "initialize", ->
      @init_triggers()
      @init_events()

      @$node.find(".actions div").each ->
        Selection.setup $(@)
