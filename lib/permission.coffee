_       = require "underscore"
onerr   = require "./errorhandler"
couchdb = require "./couchdb"

check_list = (list, user, callback) ->
  user = user.username ? user
  couchdb.connect onerr callback, (db) ->
    db.view "lists", "by_user", keys: [user], onerr callback, (body) ->
      lists = body.rows.map (row) -> row.value._id
      callback null, _.contains lists, list._id

check_bookmark = (bookmark, user, callback) ->
  user = user.username ? user
  couchdb.connect onerr callback, (db) ->
    db.view "lists", "by_user", keys: [user], onerr callback, (body) ->
      lists = body.rows.map (row) -> row.value._id
      callback null, _.contains lists, bookmark.list_id

exports.check_list = check_list
exports.check_bookmark = check_bookmark
