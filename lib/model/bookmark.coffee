crud     = require "./generic"
couchdb  = require "../couchdb"
onerr    = require "../errorhandler"
date     = require "../date"
users    = require "./user"
crypto   = require "crypto"

create = (list_id=0, title="New Bookmark", url="http://new.com") ->
  type: "bookmark"
  list_id: list_id
  title: title
  url: url
  tags: []
  created_at: date.now()

validate = (bookmark, callback) ->
  return callback new Error "Not a bookmark" unless bookmark.type is "bookmark"
  return callback new Error "No assigned list" unless bookmark.list_id?
  return callback new Error "No title" unless bookmark.title
  return callback new Error "No url" unless bookmark.url
  return callback new Error "Tags null" unless bookmark.tags?
  callback null, bookmark

get_by_tag_user = (tag, user, callback) ->
  user_id = user._id ? user
  users.fetch_lists user_id, onerr callback, (lists) ->
    keys = lists.map (list) -> [tag, list._id]

    couchdb.connect onerr callback, (db) ->
      db.list "bookmarks", "sort_by_date", "by_tag_list",
        keys: keys
      , onerr callback, (body) ->
          bookmarks = body.rows.map (row) -> row.value
          callback null, bookmarks

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
