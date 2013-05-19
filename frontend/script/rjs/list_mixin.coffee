define ->

  ->

    @filter = (_, opts) ->
      return unless opts?.text?

      text_matches = (a) ->
        a.toUpperCase().indexOf(opts.text.toUpperCase()) >= 0

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
