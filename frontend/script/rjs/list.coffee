define ["ajax", "bookmark", "list_mixin", "selection"],
  (ajax, Bookmark, list_mixin, Selection) ->

    TitleEdit = flight.component ->

      @after "initialize", ->
        @$node.keyup (e) =>
          return unless e.which is 13

          title = @$node.val()
          ajax @$node, "/list/#{@attr.id}",
            type: "POST"
            data: title: title
          , =>
            @$node.closest(".title").text title
            @trigger "#sidebar", "refresh"
            @teardown()

    flight.component ->

      flight.compose.mixin @, [list_mixin]

      @update_no_bookmarks = (_, opts) ->
        element = @$node.find "#nobookmarks-#{@attr.id}"
        count = @select("bookmark").length
        if opts?.add?
          count += opts.add

        if count > 0
          element.addClass "hidden"
        else
          element.removeClass "hidden"

      @replace_bookmark = (_, opts) ->
        @$node.find("#bookmark-#{opts.id}").replaceWith opts.html
        Bookmark.attachTo @$node.find("#bookmark-#{opts.id}"),
          id: opts.id
          list_id: @attr.id
        @trigger "#newest", "refresh"

      @new_bookmark = ->
        ajax @$node, "/bookmark/new",
          type: "POST"
          data: list: @attr.id
        , (html) =>
          @$node.find(".bookmarks ul").first().prepend html
          id = $(html).attr "id"
          element = @$node.find "##{id}"
          Bookmark.attachTo element,
            id: id.replace "bookmark-", ""
            list_id: @attr.id
          @trigger "update_no_bookmarks"
          @trigger element, "edit"

      @remove = ->
        ajax @$node, "/list/#{@attr.id}", type: "DELETE", =>
          @$node.fadeOut().remove()
          @trigger "#sidebar", "refresh"
          @trigger "#newest", "refresh"
          @teardown()

      @edit_title = ->
        title = @select("title").text()
        @select("title").html "<input type='text' />"
        element = @select("title").find "input"
        element.val title
        element.select()
        TitleEdit.attachTo element, id: @attr.id

      @defaultAttrs
        bookmark: ".bookmark"
        add: ".addbookmark"
        unsubscribe: ".delete"
        title: ".title"
        sharing: ".edit"

      @init_triggers = ->
        @on "replace_bookmark", @replace_bookmark
        @on "filter", @filter
        @on "update_no_bookmarks", @update_no_bookmarks
        @on "delete_list", @remove
        @on "edit_title", @edit_title

      @after "initialize", ->
        @init_triggers()

        @select("add").click => @new_bookmark()
        @select("unsubscribe").click =>
          if confirm "Unsubscribe from #{@select("title").text()}?"
            @trigger "delete_list"
        @select("title").click =>
          @edit_title() unless @select("title").find("input").length > 0
        @select("sharing").click =>
          @trigger ".overlay", "show_sharing", id: @attr.id

        @$node.find(".bookmark").each (_, element) =>
          bookmark_id = $(element).attr("id").replace "bookmark-", ""
          Bookmark.attachTo $(element), id: bookmark_id, list_id: @attr.id

        @$node.find(".bookmarklet").each ->
          url = $(@).attr "href"
          url = url.replace "bm.smattr.de", window.location.host
          $(@).attr "href", url

        Selection.setup @$node.find(".button")
        Selection.setup @$node.find(".title")
        @$node.find(".list_header .actions div").each ->
          Selection.setup $(@)
