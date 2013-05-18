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
    callback? user

exports.fill_test_list = (name, user, callback) ->
  list = lists.create user, name
  lists.insert list, (err, list) ->
    throw err if err?
    callback? list

exports.fill_sharing_users = (callback) ->
  exports.fill_test_user "user1", ->
    exports.fill_test_user "user2", ->
      exports.fill_test_list "list1", "user1", (list) ->
        db.get list._id, (err, list) ->
          throw err if err?
          list.users.push "user2"
          db.insert list, (err, list) ->
            throw err if err?
            callback? list
