onerr   = require "../lib/errorhandler"
couchdb = require "../lib/couchdb"
async   = require "async"

get = (req, res, next) ->
  get_user_data req.session.user, onerr next, (user) ->
    res.render "overview", user: user

get_user_data = (username, callback) ->
  couchdb.connect onerr callback, (db) ->
    db.get username, onerr callback, (user) ->
      fill_lists db, user, onerr callback, ->
        tasks = user.lists.map (list) ->
          (callback) -> fill_bookmarks db, list, callback
        async.parallel tasks, -> callback null, user

fill_lists = (db, user, callback) ->
  db.view "lists", "by_user",
    keys: [user._id]
  , onerr callback, (body) ->
      user.lists = body.rows.map (row) -> row.value
      callback()

fill_bookmarks = (db, list, callback) ->
  list.bookmarks = []
  db.view "bookmarks", "by_list",
    keys: [list._id]
  , onerr callback, (body) ->
      for row in body.rows
        list.bookmarks.push row.value
      callback()

exports.get = get
