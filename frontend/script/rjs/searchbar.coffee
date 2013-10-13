define ->

  flight.component ->

    @timer = null

    @search = (_, opts) ->
      clearTimeout @timer if @timer?
      if opts?.text
        @select("input").val opts.text
        @select("input").select()

      $(".list").each (_, e) =>
        @trigger e, "filter", text: @select("input").val()

    @defaultAttrs
      input: "input"

    @after "initialize", ->
      @on "search", @search

      @select("input").keyup =>
        clearTimeout @timer if @timer?
        @timer = setTimeout (=> @search()), 300

      @select("input").select()

      # Scroll to and focus search bar when the 's' shortcut is pressed
      $("body").keyup (e) =>
        # Only on 's'
        return unless e.which is 83

        # Only when user is not doing input operations
        return if document.activeElement.tagName is "INPUT"

        @select("input").select()
        $("html, body").animate {
          scrollTop: @select("input").offset().top
        }, 0

