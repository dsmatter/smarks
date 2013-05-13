db        = require("../lib/couchdb")()
_         = require "underscore"
onerr     = require "../lib/errorhandler"
users     = require "../lib/model/user"
lists     = require "../lib/model/list"
bookmarks = require "../lib/model/bookmark"

get_lists = (req, res, next) ->
  users.fetch_lists req.session.user, onerr next, (lists) ->
    result = lists.map (list) -> [list._id, list.title]
    res.end JSON.stringify(result)

get_all_bookmarks = (req, res, next) ->
  users.fetch_lists req.session.user, onerr next, (lists) ->
    # Map list id -> title
    listid_title = {}
    for list in lists
      listid_title[list._id] = list.title

    # Initialize result object
    result = {}
    for list in lists
      result[list.title] = []

    keys = lists.map (list) -> list._id
    db.list "bookmarks", "sort_by_date", "by_list",
      keys: keys
    , onerr next, (body) ->
        for row in body.rows
          title = listid_title[row.key]
          result[title].push bookmark_json row.value

        res.end JSON.stringify result

get_bookmarks = (req, res, next) ->
  lists.fetch_bookmarks req.params.id, onerr next, (bookmarks) ->
    result = []
    for bookmark in bookmarks
      result.push bookmark_json bookmark
    res.end JSON.stringify result

add_bookmark = (req, res, next) ->
  list_id = req.param "list"
  title = req.param "title"
  url = req.param "url"

  return res.send 400 unless title and url

  users.fetch_lists req.session.user, onerr next, (lists) ->
    # Use first list, if not specified
    list_id ?= lists[0]?._id

    # Permission check
    return res.send 403 unless _.any lists, (list) -> list_id is list._id

    new_bookmark = bookmarks.create list_id, title, url
    bookmarks.insert new_bookmark, onerr next, ->
      res.end()

bookmark_json = (bookmark) ->
  title: bookmark.title
  url: bookmark.url
  tags: bookmark.tags

exports.get_lists = get_lists
exports.get_all_bookmarks = get_all_bookmarks
exports.get_bookmarks = get_bookmarks
exports.add_bookmark = add_bookmark
