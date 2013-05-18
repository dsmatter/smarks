nano    = require("nano")("http://localhost:5984")
init_db = require "../util/init_db"
db      = require("../lib/couchdb")("test")
users   = require "../lib/model/user"
lists   = require "../lib/model/list"

exports.init_db = (name, callback) ->
  nano.db.destroy name, (err) ->
    init_db name, callback

exports.fill_test_user = (name, callback) ->
  user = users.create name
  users.insert user, (err, user) ->
    throw err if err?
    callback?(user)

exports.fill_test_list = (name, user, callback) ->
  list = lists.create user, name
  lists.insert list, (err, list) ->
    throw err if err?
    callback?(list)
