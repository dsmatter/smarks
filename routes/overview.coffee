users   = require "../lib/model/user"
lists   = require "../lib/model/list"
onerr   = require "../lib/errorhandler"
couchdb = require "../lib/couchdb"
_       = require "underscore"

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
            for row in body.rows
              list_bookmarks[row.key].push row.value

            all_bookmarks = _.flatten(_.values list_bookmarks)
            all_bookmarks = _.sortBy all_bookmarks, "created_at"
            user.newest = (_.last all_bookmarks, 10).reverse()
            res.render "overview", user: user

exports.get = get
