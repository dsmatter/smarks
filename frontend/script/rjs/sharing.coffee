define ["ajax", "selection"], (ajax, Selection) ->

  SharingUser = flight.component ->

    @after "initialize", ->
      @attr.id = @$node.attr("id").replace "user-", ""
      @$node.find(".delete").click =>
        @trigger "delete_user", user_id: @attr.id

      Selection.setup @$node

  SharingFriends = flight.component ->

    @after "initialize", ->
      @$node.find(".user").each (_, e) =>
        user_id = $(e).attr("id").replace "user-", ""
        $(e).click =>
          @trigger "add_user", user_id: user_id

      Selection.setup @$node.find(".user")


  flight.component ->

    @delete_user = (_, opts) ->
      elem = @$node.find "#user-#{opts.user_id}"
      ajax elem, "/lists/sharing/#{@attr.id}/user/#{opts.user_id}",
        type: "DELETE"
      , =>
        elem.fadeOut().remove()
        @trigger "refresh_friends"
        @trigger "#lists", "refresh_list", id: @attr.id

    @refresh_friends = ->
      elem = @$node.find("#add_friends")
      ajax elem, "/lists/sharing/#{@attr.id}/friends", (html) =>
        elem.replaceWith html
        SharingFriends.attachTo @$node.find("#add_friends")

    @add_user = (_, opts) ->
      elem = @$node.find "#users"
      ajax elem, "/lists/sharing/#{@attr.id}/add", data: opts, (html) =>
        elem.append html
        SharingUser.attachTo @$node.find("#users .user").last()
        @trigger "refresh_friends"
        @trigger "#lists", "refresh_list", id: @attr.id

    @after "initialize", ->
      @on "delete_user", @delete_user
      @on "refresh_friends", @refresh_friends
      @on "add_user", @add_user

      @$node.find("#adduser").click =>
        @$node.find("#adduser_form").removeClass "hidden"

      @$node.find(".user").each (_, e) =>
        SharingUser.attachTo $(e)

      SharingFriends.attachTo @$node.find("#add_friends")

      @$node.find("#email").keyup (e) =>
        @trigger "add_user", user_email: $(e.target).val() if e.which is 13

      Selection.setup @$node.find(".button")
