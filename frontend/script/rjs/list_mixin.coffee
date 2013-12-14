define ->

  ->

    @filter = (e, opts) ->
      return unless opts?.text?

      # Special case for empty search string
      # Otherwise a list w/o bookmarks wouldn't be shown
      if opts.text is ""
        @select("bookmark").show()
        @$node.show()
        @trigger "#sidebar", "refresh"
        return

      text_matches = (a) ->
        searchWords = opts.text.split(" ")
        indices = _.map searchWords, (word) ->
          a.toUpperCase().indexOf(word.toUpperCase())
        _.all indices, (i) -> i >= 0

      matches = (bookmark) ->
        title = bookmark.find(".link a").first().text()
        return true if text_matches title

        tags = bookmark.find(".tags a")
        window._.any tags, (tag) -> text_matches $(tag).text()

      any_match = false
      @select("bookmark").each ->
        if matches $(@)
          any_match = true
          $(@).show()
        else
          $(@).hide()

      if any_match
        @$node.show()
      else
        @$node.hide()

      @trigger "#sidebar", "refresh"
