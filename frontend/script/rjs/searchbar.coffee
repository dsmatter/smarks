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
