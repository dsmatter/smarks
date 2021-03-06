db     = require("../couchdb")()
crud   = require "./generic"
onerr  = require "../errorhandler"
date   = require "../date"
crypto = require "crypto"
auth   = require "../auth"

create = (name="user") ->
  _id: name
  type: "user"
  username: name
  email: ""
  active: true
  tokens: []
  salt: crypto.randomBytes(10).toString "hex"
  password: crypto.randomBytes(20).toString "hex"
  created_at: date.now()

validate = (user, callback) ->
  return callback new Error "Not a user" unless user.type is "user"
  return callback new Error "No username" unless user.username
  return callback new Error "No salt" unless user.salt
  return callback new Error "No password" unless user.password
  callback null, user

set_password = (user, pass) ->
  user.password = auth.calculate_hash pass, user.salt

get_by_email = (email, callback) ->
  db.view "users", "by_email", key: email, onerr callback, (body) ->
    user = body.rows[0]?.value
    callback null, user

get_by_token = (token, callback) ->
  db.view "users", "by_token", key: token, onerr callback, (body) ->
    user = body.rows[0]?.value
    callback null, user

fetch_lists = (user, callback) ->
  user_id = user._id ? user
  db.list "lists", "sort_by_title", "by_user",
    keys: [user_id]
  , onerr callback, (body) ->
      lists = body.rows.map (row) -> row.value
      user.lists = lists
      callback null, lists

fetch_friends = (user, callback) ->
  user_id = user._id ? user
  db.view "friends", "by_user",
    group: true
    startkey: [user_id]
    endkey: [user_id, {}]
  , (err, body) ->
      friends = body.rows.map (row) -> row.key[1]
      user.friends = friends
      callback null, friends

generate_token = (user, callback) ->
  user_id = user._id ? user
  token = crypto.randomBytes(20).toString "hex"

  exports.get user_id, onerr callback, (user) ->
    user.tokens.push token
    exports.insert user, callback

crud.infect exports, validate
exports.create = create
exports.validate = validate
exports.get_by_email = get_by_email
exports.get_by_token = get_by_token
exports.fetch_lists = fetch_lists
exports.fetch_friends = fetch_friends
exports.generate_token = generate_token
exports.set_password = set_password
