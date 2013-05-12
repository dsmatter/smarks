onerr      = require "../lib/errorhandler"
couchdb    = require "../lib/couchdb"
dateformat = require "dateformat"
_          = require "underscore"

create = (req, res, next) ->
  list =
    type: "list"
    title: "New List"
    created_at: dateformat(new Date(), "yyyy-mm-dd HH:MM")
    users: [req.session.user]
    bookmarks: []

  couchdb.connect onerr next, (db) ->
    db.insert list, onerr next, (body) ->
      list._id = body.id
      res.render "partial_list", list: list

remove = (req, res, next) ->
  couchdb.connect onerr next, (db) ->
    db.get req.params.id, onerr next, (list) ->
      for _, i in list.users
        delete list.users[i]
        break

      finalize = onerr next, -> res.end()
      if list.users.length == 0
        db.destroy list._id, list._rev, finalize
      else
        db.insert list, finalize

post = (req, res, next) ->
  title = req.param "title"
  unless title?
    res.end()
    return

  couchdb.connect onerr next, (db) ->
    db.get req.params.id, onerr next, (list) ->
      unless _.contains list.users, req.session.user
        res.send 403
        return

      list.title = title
      db.insert list, onerr next, ->
        res.end()

exports.create = create
exports.remove = remove
exports.post   = post
