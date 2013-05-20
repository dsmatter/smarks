db     = require("../couchdb")()
crud   = require "./generic"
onerr  = require "../errorhandler"
date   = require "../date"
users  = require "./user"
crypto = require "crypto"
_      = require "underscore"

create = (list_id=0, title="New Bookmark", url="http://new.com") ->
  result =
    type: "bookmark"
    list_id: list_id
    title: title
    url: url
    tags: []
    created_at: date.now()
  set_title result, title
  result

validate = (bookmark, callback) ->
  return callback new Error "Not a bookmark" unless bookmark.type is "bookmark"
  return callback new Error "No assigned list" unless bookmark.list_id?
  return callback new Error "No title" unless bookmark.title
  return callback new Error "No url" unless bookmark.url
  return callback new Error "Tags null" unless bookmark.tags?

  # Encode common characters
  bookmark.url = bookmark.url.replace(/\ /g, "%20")
                             .replace(/!/g, "%21")
                             .replace(/\+/g, "%2B")

  callback null, bookmark

get_by_tag_user = (tag, user, callback) ->
  user_id = user._id ? user
  users.fetch_lists user_id, onerr callback, (lists) ->
    keys = lists.map (list) -> [tag, list._id]

    db.list "bookmarks", "sort_by_date", "by_tag_list",
      keys: keys
    , onerr callback, (body) ->
        bookmarks = body.rows.map (row) -> row.value
        callback null, bookmarks

get_newest = (user, limit, callback) ->
  user_id = user._id ? user
  users.fetch_lists user_id, onerr callback, (lists) ->
    keys = lists.map (list) -> list._id

    db.list "bookmarks", "sort_by_date", "by_list",
      keys: keys
    , onerr callback, (body) ->
        bookmarks = body.rows.map (row) -> row.value
        newest = _.first bookmarks, limit
        user.newest = newest
        callback null, newest

set_title = (bookmark, title_with_tags) ->
  [title, tags] = split_title title_with_tags
  bookmark.title = title
  bookmark.tags = tags
  bookmark

split_title = (title_with_tags) ->
  title = title_with_tags.match(/^(.+?) @/)?[1]
  return [title_with_tags, []] unless title?
  tags = title_with_tags.match /\s@(\S+)/g ? []
  tags = tags.map (tag) -> tag.substring 2
  [title, tags]

crud.infect exports, validate
exports.create = create
exports.validate = validate
exports.set_title = set_title
exports.get_by_tag_user = get_by_tag_user
exports.get_newest = get_newest
