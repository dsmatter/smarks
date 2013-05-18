db     = require("./couchdb")()
onerr  = require "./errorhandler"
users  = require "./model/user"
async  = require "async"

create = (page, user) ->
  user_id = user._id ? user

  type: "cache"
  page: page
  user_id: user_id
  valid: false

get = (page, user, callback) ->
  user_id = user._id ? user

  db.view "cache", "by_user_page", key: [user_id, page], onerr callback, (body) ->
    callback null, body.rows[0]?.value

get_users = (page, users, callback) ->
  keys = users.map (user) ->
    user_id = user._id ? user
    [user_id, page]

  db.view "cache", "by_user_page", keys: keys, onerr callback, (body) ->
    callback null, body.rows.map (row) -> row.value

set = (page, user, content, callback) ->
  get page, user, onerr callback, (cache_entry) ->
    cache_entry ?= create page, user
    cache_entry.content = content
    cache_entry.valid = true

    db.insert cache_entry, callback

invalidate = (page, user, callback) ->
  get page, user, onerr callback, (cache_entry) ->
    return callback() unless cache_entry?
    cache_entry.valid = false

    db.insert cache_entry, callback

invalidate_friend_overviews = (user, callback) ->
  user_id = user._id ? user

  users.fetch_friends user_id, onerr callback, (friends) ->
    friends.push user_id
    tasks = friends.map (user) ->
      (c) -> invalidate "overview", user, onerr callback, c
    async.parallel tasks, -> callback()

middleware_invalidate_overview = (req, res, next) ->
  invalidate_friend_overviews req.session.user, next

exports.get = get
exports.set = set
exports.create = create
exports.invalidate = invalidate
exports.invalidate_friend_overviews = invalidate_friend_overviews
exports.middleware_invalidate_overview = middleware_invalidate_overview
