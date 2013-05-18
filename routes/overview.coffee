db        = require("../lib/couchdb")()
users     = require "../lib/model/user"
lists     = require "../lib/model/list"
bookmarks = require "../lib/model/bookmark"
onerr     = require "../lib/errorhandler"
cache     = require "../lib/cache"
_         = require "underscore"

get = (req, res, next) ->
  # Try cache
  cache.get "overview", req.session.user, onerr next, (cache_entry) ->
    if cache_entry?.valid
      console.log "from cache"
      render_html res, cache_entry.content
      return

    # Get data from database
    users.get req.session.user, onerr next, (user) ->
      users.fetch_lists user, onerr next, ->
        db.list "bookmarks", "sort_by_date", "by_list",
          keys: user.lists.map (list) -> list._id
        , onerr next, (body) ->
            list_bookmarks = {}
            for list in user.lists
              list.bookmarks = []
              list_bookmarks[list._id] = list.bookmarks

            i = 0
            user.newest = []
            for row in body.rows
              user.newest.push row.value if i++ < 10
              list_bookmarks[row.key].push row.value

            res.render "overview", user: user, onerr next, (body) ->
              cache.set "overview", user, body, onerr next, -> #ignore
              render_html res, body

get_newest = (req, res, next) ->
  bookmarks.get_newest req.session.user, 10, onerr next, (bookmarks) ->
    res.render "partial_bookmarks",
      id: "newest"
      title: "Newest Bookmarks"
      bookmarks: bookmarks

render_html = (res, body) ->
  res.charset = "utf-8"
  res.type "html"
  res.end body

exports.get = get
exports.get_newest = get_newest
