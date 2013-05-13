sqlite  = require "sqlite3"
moment  = require "moment"
nano    = require("nano")("http://localhost:5984")

source_db_path = process.argv[2]
throw new Error "No database file given" unless source_db_path?

sql_db = new sqlite.Database source_db_path, sqlite.OPEN_READONLY

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


# Helper function to overwrite an existing document
overwrite_item = (db, id, obj, callback) ->
  db.get id, (err, old_obj) ->
    if old_obj?
      obj._rev = old_obj._rev
    db.insert obj, id, callback


### Run import ###
db = nano.db.use "bookmarks"
add_users db
add_lists db
add_bookmarks db
