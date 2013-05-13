users      = require "../lib/model/user"
lists      = require "../lib/model/list"
onerr      = require "../lib/errorhandler"
permission = require "../lib/permission"
dateformat = require "dateformat"
_          = require "underscore"

create = (req, res, next) ->
  new_list = lists.create req.session.user
  lists.insert new_list, onerr next, (new_list) ->
    new_list.bookmarks = []
    res.render "partial_list", list: new_list

get = (req, res, next) ->
  lists.get req.params.id, onerr next, (list) ->
    permission.assert_list res, list, req.session.user, onerr next, ->
      lists.fetch_bookmarks list, onerr next, ->
        res.render "partial_list", list: list

remove = (req, res, next) ->
  lists.get req.params.id, onerr next, (list) ->
    list.users = _.without list.users, req.session.user

    finalize = onerr next, -> res.end()
    if list.users.length == 0
      lists.destroy list, finalize
    else
      lists.insert list, finalize

post = (req, res, next) ->
  title = req.param "title"
  unless title?
    res.end()
    return

  lists.get req.params.id, onerr next, (list) ->
    permission.assert_list res, list, req.session.user, onerr next, ->
      list.title = title
      lists.insert list, onerr next, ->
        res.end()

sharing = (req, res, next) ->
  lists.get req.params.id, onerr next, (list) ->
    permission.assert_list res, list, req.session.user, onerr next, ->
      users.fetch_friends req.session.user, onerr next, (friends) ->
        res.render "partial_sharing", friends: friends, list: list

sharing_add = (req, res, next) ->
  new_user_id = req.param "user_id"
  new_user_email = req.param "user_email"

  lists.get req.params.list_id, onerr next, (list) ->
    permission.assert_list res, list, req.session.user, onerr next, ->
      finalize = (new_user_id) ->
        list.users.push new_user_id unless _.contains list.users, new_user_id
        lists.insert list, onerr next, (list) ->
          res.render "partial_sharing_user", user: new_user_id

      if new_user_id?
        users.fetch_friends req.session.user, onerr next, (friends) ->
          return res.end 403 unless _.contains friends, new_user_id
          finalize new_user_id
      else
        users.get_by_email new_user_email, onerr next, (new_user) ->
          finalize new_user._id

sharing_delete = (req, res, next) ->
  list_id = req.params.list_id
  user_id = req.params.user_id

  # Can't delete yourself
  res.send 400 if user_id is req.session.user

  lists.get list_id, onerr next, (list) ->
    permission.assert_list res, list, req.session.user, onerr next, ->
      list.users = _.without list.users, user_id
      lists.insert list, onerr next, ->
        res.end()

exports.create         = create
exports.get            = get
exports.remove         = remove
exports.post           = post
exports.sharing        = sharing
exports.sharing_add    = sharing_add
exports.sharing_delete = sharing_delete
