define ["ajax", "sharing"], (ajax, Sharing) ->

  flight.component ->

    @show_sharing = (_, opts) ->
      ajax $("body"), "/lists/sharing/#{opts.id}", (html) =>
        @$node.find(".centerbox").html html
        @$node.removeClass "hidden"
        Sharing.attachTo @$node.find("#sharing"), id: opts.id

    @defaultAttrs
      box: ".centerbox"

    @after "initialize", ->
      @on "show_sharing", @show_sharing

      @$node.click => @$node.addClass "hidden"
      @select("box").click => false
