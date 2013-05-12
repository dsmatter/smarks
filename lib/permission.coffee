_       = require "underscore"
onerr   = require "./errorhandler"
couchdb = require "./couchdb"

check_list = (list, user, callback) ->
  user = user.username ? user

  if list instanceof Object and list.users instanceof Array
    callback null, _.contains list.users, user
    return

  couchdb.connect onerr callback, (db) ->
    db.view "lists", "by_user", keys: [user], onerr callback, (body) ->
      lists = body.rows.map (row) -> row.value._id
      callback null, _.contains lists, list

check_bookmark = (bookmark, user, callback) ->
  user = user.username ? user
  couchdb.connect onerr callback, (db) ->
    db.view "lists", "by_user", keys: [user], onerr callback, (body) ->
      lists = body.rows.map (row) -> row.value._id
      callback null, _.contains lists, bookmark.list_id

assert_granted = (res, check, callback) ->
  check onerr callback, (granted) ->
    if granted
      callback null, true
    else
      res.send 403

assert_list = (res, list, user, callback) ->
  check = (c) -> check_list list, user, c
  assert_granted res, check, callback

assert_bookmark = (res, bookmark, user, callback) ->
  check = (c) -> check_bookmark bookmark, user, c
  assert_granted res, check, callback

exports.check_list = check_list
exports.check_bookmark = check_bookmark
exports.assert_list = assert_list
exports.assert_bookmark = assert_bookmark
