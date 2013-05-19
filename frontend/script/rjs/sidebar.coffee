define ->

  flight.component ->

    @create_list_element = (id, title) ->
      list_id = id.replace "navi-", ""
      "<li id='#{id}'><a href='##{list_id}'><i class='icon-chevron-right right'></i>#{title}</a></li>"

    @get_selected = ->
      result = null
      @select("entry").each ->
        if $(@).hasClass "active"
          result = $(@)
      result

    @position = ->
      content_pos = $("#content").position()
      width = @$node.width()
      padding_left = 80
      pos_top = content_pos.top
      pos_left = content_pos.left - width - padding_left
      pos_left = 5 if pos_left < 0

      @$node.css "position", "fixed"
      @$node.css "top", pos_top
      @$node.css "left", pos_left

    @init = ->
      @fill()
      @position()
      @select("entry").first().addClass "active"
      $("body").scrollspy "refresh"
      @$node.show()

    @fill = ->
      $(".list:visible").each (_, elem) =>
        elem = $(elem)
        id = "navi-#{elem.attr "id"}"
        title = elem.find(".title").text()
        @select("list").append @create_list_element id, title

    @refresh = ->
      selected_id = @get_selected()?.attr "id"
      @select("entry").remove()
      @fill()

      to_select = @$node.find("##{selected_id}")
      to_select = @select("entry").first() if to_select.length is 0
      to_select.addClass "active"

      $("body").scrollspy "refresh"

    @defaultAttrs
      list: "ul"
      entry: "li"

    @after "initialize", ->
      @on "init", @init
      @on "refresh", @refresh

      @trigger "init"
