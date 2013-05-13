_          = require "underscore"
users      = require "../lib/model/user"
lists      = require "../lib/model/list"
bookmarks  = require "../lib/model/bookmark"
onerr      = require "../lib/errorhandler"
permission = require "../lib/permission"
dateformat = require "dateformat"

create = (req, res, next) ->
  list_id = req.param "list"
  permission.check_list list_id, req.session.user, onerr next, (allowed) ->
    return res.send 403 unless allowed

    bookmark = bookmarks.create list_id
    bookmarks.insert bookmark, onerr next, (bookmark) ->
      res.render "partial_bookmark", bookmark: bookmark

remove = (req, res, next) ->
  bookmarks.get req.params.id, onerr next, (bookmark) ->
    permission.check_bookmark bookmark, req.session.user, onerr next, (allowed) ->
      return res.send 403 unless allowed
      bookmarks.destroy bookmark, onerr next, ->
        res.end()

get = (req, res, next) ->
  users.fetch_lists req.session.user, onerr next, (lists) ->
    bookmarks.get req.params.id, onerr next, (bookmark) ->
      return res.send 403 unless _.any(lists, (list) -> list._id is bookmark.list_id)

      bookmark.title_with_tags = bookmark.title
      bookmark.title_with_tags += " @#{tag}" for tag in bookmark.tags
      res.render "partial_edit_bookmark",
        bookmark: bookmark
        lists: lists

post = (req, res, next) ->
  title_with_tags = req.param "title"
  url = req.param "url"
  return res.send 400 unless title_with_tags and url

  bookmarks.get req.params.id, onerr next, (bookmark) ->
    permission.check_bookmark bookmark, req.session.user, onerr next, (allowed) ->
      return res.send 403 unless allowed
      bookmarks.set_title bookmark, title_with_tags
      bookmark.url = url

      bookmarks.insert bookmark, onerr next, (bookmark) ->
        res.render "partial_bookmark", bookmark: bookmark

quick_get = (req, res, next) ->
  locals =
    title: req.param("title") ? "New Bookmark"
    url: req.param("url") ? "http://newbookmark.com"
    list_id: req.param "list"

  users.fetch_lists req.session.user, onerr next, (lists) ->
    locals.lists = lists
    res.render "quick_new", locals

quick_post = (req, res, next) ->
  list_id = req.param "list"
  title_with_tags = req.param "title"
  url = req.param "url"

  permission.check_list list_id, req.session.user, onerr next, (allowed) ->
    return res.send 403 unless allowed

    bookmark = bookmarks.create list_id, null, url
    bookmarks.set_title bookmark, title_with_tags

    bookmarks.insert bookmark, onerr next, ->
      res.redirect "/success"

move = (req, res, next) ->
  bookmark_id = req.params.bookmark_id
  list_id = req.params.list_id

  permission.check_list list_id, req.session.user, onerr next, (allowed) ->
    return res.send 403 unless allowed

    bookmarks.get bookmark_id, onerr next, (bookmark) ->
      permission.assert_bookmark res, bookmark, req.session.user, onerr next, ->
        old_list_id = bookmark.list_id

        bookmarks.update bookmark._id, list_id: list_id, onerr next, (bookmark) ->
          lists.get old_list_id, onerr next, (old_list) ->
            lists.fetch_bookmarks old_list, onerr next, ->
              res.render "partial_list", list: old_list

get_by_tag = (req, res, next) ->
  bookmarks.get_by_tag_user req.params.tag, req.session.user, onerr next, (bookmarks) ->
    res.render "bookmarks",
      user: username: req.session.user
      bookmarks: bookmarks
      title: "Tagged with #{req.params.tag}"
      id: req.params.tag

exports.create = create
exports.remove = remove
exports.get = get
exports.post = post
exports.quick_get = quick_get
exports.quick_post = quick_post
exports.move = move
exports.get_by_tag = get_by_tag
