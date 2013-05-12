crud     = require "./generic"
couchdb  = require "../couchdb"
onerr    = require "../errorhandler"
date     = require "../date"
crypto   = require "crypto"

create = (user, title="New List") ->
  type: "list"
  title: title
  users: [user]
  created_at: date.now()

validate = (list, callback) ->
  return callback new Error "Not a list" unless list.type is "list"
  return callback new Error "No title" unless list.title
  return callback new Error "No users" unless list.users? and list.users.length > 0
  callback null, list

fetch_bookmarks = (list, callback) ->
  couchdb.connect onerr callback, (db) ->
    db.list "bookmarks", "sort_by_date", "by_list",
      key: list._id
    , onerr callback, (body) ->
        bookmarks = body.rows.map (row) -> row.value
        list.bookmarks = bookmarks
        callback null, bookmarks

crud.infect exports, validate
exports.create = create
exports.validate = validate
exports.fetch_bookmarks = fetch_bookmarks
