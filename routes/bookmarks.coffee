_          = require "underscore"
onerr      = require "../lib/errorhandler"
couchdb    = require "../lib/couchdb"
permission = require "../lib/permission"
dateformat = require "dateformat"

create = (req, res, next) ->
  list_id = req.param "list"

  couchdb.connect onerr next, (db) ->
    db.get list_id, onerr next, (list) ->
      unless _.contains list.users, req.session.user
        res.send 403
        return

    bookmark =
      type: "bookmark"
      title: "New Bookmark"
      url: "http://newbookmark.com"
      tags: []
      list_id: list_id

    db.insert bookmark, onerr next, (body) ->
      bookmark._id = body.id
      res.render "partial_bookmark", bookmark: bookmark

remove = (req, res, next) ->
  couchdb.connect onerr next, (db) ->
    db.get req.params.id, onerr next, (bookmark) ->
      db.get bookmark.list_id, onerr next, (list) ->
        unless _.contains list.users, req.session.user
          res.send 403
          return

        db.destroy bookmark._id, bookmark._rev, onerr next, ->
          res.end()

get = (req, res, next) ->
  couchdb.connect onerr next, (db) ->
    db.view "lists", "by_user", keys: [req.session.user], onerr next, (body) ->
      lists = body.rows.map (row) -> row.value
      db.get req.params.id, onerr next, (bookmark) ->
        unless _.any(lists, (list) -> list._id is bookmark.list_id)
          res.send 403
          return

        bookmark.title_with_tags = bookmark.title
        bookmark.title_with_tags += " @#{tag}" for tag in bookmark.tags
        res.render "partial_edit_bookmark",
          bookmark: bookmark
          lists: lists

post = (req, res, next) ->
  title_with_tags = req.param "title"
  url = req.param "url"
  return res.send 400 unless title_with_tags and url

  couchdb.connect onerr next, (db) ->
    db.get req.params.id, onerr next, (bookmark) ->
      permission.check_bookmark bookmark, req.session.user, onerr next, (allowed) ->
        return res.send 403 unless allowed
        [title, tags] = split_title title_with_tags
        bookmark.title = title if title
        bookmark.tags = tags
        bookmark.url = url

        db.insert bookmark, onerr next, (body) ->
          bookmark._id = body.id
          res.render "partial_bookmark", bookmark: bookmark

quick_get = (req, res, next) ->
  locals =
    title: req.param "title" ? "New Bookmark"
    url: req.param "url" ? "http://newbookmark.com"
    list_id: req.param "list"

  couchdb.connect onerr next, (db) ->
    db.view "lists", "by_user", keys: [req.session.user], onerr next, (body) ->
      locals.lists = body.rows.map (row) -> row.value
      res.render "quick_new", locals

split_title = (title_with_tags) ->
  title = title_with_tags.match(/^(.+?) @/)?[1]
  return [title_with_tags, []] unless title?
  tags = title_with_tags.match /\s@(\S+)/g ? []
  tags = tags.map (tag) -> tag.substring 2
  [title, tags]

exports.create = create
exports.remove = remove
exports.get = get
exports.post = post
exports.quick_get = quick_get
