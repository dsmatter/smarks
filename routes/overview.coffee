users     = require "../lib/model/user"
lists     = require "../lib/model/list"
bookmarks = require "../lib/model/bookmark"
onerr     = require "../lib/errorhandler"
couchdb   = require "../lib/couchdb"
_         = require "underscore"

get = (req, res, next) ->
  users.get req.session.user, onerr next, (user) ->
    users.fetch_lists user, onerr next, ->
      couchdb.connect onerr next, (db) ->
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

            res.render "overview", user: user

get_newest = (req, res, next) ->
  bookmarks.get_newest req.session.user, 10, onerr next, (bookmarks) ->
    res.render "partial_bookmarks",
      id: "newest"
      title: "Newest Bookmarks"
      bookmarks: bookmarks

exports.get = get
exports.get_newest = get_newest
