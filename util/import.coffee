sqlite  = require "sqlite3"
moment  = require "moment"
couchdb = require "../lib/couchdb"

source_db_path = process.argv[2]
throw new Error "No database file given" unless source_db_path?

sql_db = new sqlite.Database source_db_path, sqlite.OPEN_READONLY

couchdb.connect (err, db) ->
  throw err if err?
  add_users db
  add_lists db
  add_bookmarks db
  add_views db

moment_format = "YYYY-MM-DD HH:mm"
format_created_at = (doc) ->
  doc.created_at = moment(doc.created_at).format moment_format

add_users = (db) ->
  sql_db.each "SELECT * FROM users", (err, user) ->
    throw err if err?

    user.type = "user"
    user.active = user.active is "t"
    user.tokens = []
    format_created_at user

    sql_db.each "SELECT key FROM tokens WHERE user_id = #{user.id}", ((err, token) ->
      throw err if err?
      user.tokens.push token.key
    ), ->
      delete user.id
      overwrite_item db, user.username, user, (err) ->
        throw err if err?

add_lists = (db) ->
  sql_db.each "SELECT * FROM lists", (err, list) ->
    throw err if err?

    list.type = "list"
    list.users = []
    format_created_at list

    q = "SELECT * FROM lists_users lu, users u WHERE lu.user_id = u.id AND lu.list_id = #{list.id}"
    sql_db.each q, ((err, user) ->
      throw err if err?
      list.users.push user.username
    ), ->
      id = "list-#{list.id}"
      delete list.id
      overwrite_item db, id, list, (err) ->
        throw err if err?

add_bookmarks = (db) ->
  sql_db.each "SELECT * FROM bookmarks", (err, bookmark) ->
    throw err if err?

    bookmark.type = "bookmark"
    bookmark.list_id = "list-#{bookmark.list_id}"
    bookmark.tags = []
    format_created_at bookmark

    q = "SELECT * FROM tags t, bookmarks_tags bt WHERE t.id = bt.tag_id AND bt.bookmark_id = #{bookmark.id}"
    sql_db.each q, ((err, tag) ->
      throw err if err?
      bookmark.tags.push tag.name
    ), ->
      id = "bookmark-#{bookmark.id}"
      delete bookmark.id
      overwrite_item db, id, bookmark, (err) ->
        throw err if err?

add_views = (db) ->
  sort_by = (key, descending=false) ->
    f = (key, descending) ->
      (head, req) ->
        rows = []
        while row = getRow()
          rows.push row
        rows = rows.sort (a, b) ->
          result =
            if a.value[key] < b.value[key]
              -1
            else if a.value[key] > b.value[key]
              1
            else
              0
          result *= -1 if descending
          result
        head.rows = rows
        send JSON.stringify(head)

    # Call f with our parameters
    "(#{f.toString()})('#{key}', #{descending})"

  design_bookmarks =
    views:
      by_list:
        map: (doc) ->
          return unless doc.type is "bookmark"
          emit doc.list_id, doc
      by_tag_list:
        map: (doc) ->
          return unless doc.type is "bookmark"
          for tag in doc.tags
            emit [tag, doc.list_id], doc
    lists:
      sort_by_date: sort_by("created_at", true)

  design_lists =
    views:
      by_user:
        map: (doc) ->
          return unless doc.type is "list"
          for user in doc.users
            emit user, doc
    lists:
      sort_by_date: sort_by("created_at", true)
      sort_by_title: sort_by("title")

  design_friends =
    views:
      by_user:
        map: (doc) ->
          return unless doc.type is "list"
          for user in doc.users
            for friend in doc.users
              emit [user, friend], 1 unless user is friend
        reduce: "_count"

  design_users =
    views:
      by_email:
        map: (doc) ->
          return unless doc.type is "user"
          emit doc.email, doc

  overwrite_item db, "_design/bookmarks", design_bookmarks, (err) ->
    throw err if err?
  overwrite_item db, "_design/lists", design_lists, (err) ->
    throw err if err?
  overwrite_item db, "_design/users", design_users, (err) ->
    throw err if err?
  overwrite_item db, "_design/friends", design_friends, (err) ->
    throw err if err?

# Helper function to overwrite an existing document
overwrite_item = (db, id, obj, callback) ->
  db.get id, (err, old_obj) ->
    if old_obj?
      obj._rev = old_obj._rev
    db.insert obj, id, callback
