nano = require("nano")("http://localhost:5984")

init = (name, callback) ->
  if typeof name is "function"
    callback = name
    name = "bookmarks"

  nano.db.create name, (err) ->
    if err? and err.error isnt "file_exists"
      console.log "CouchDB connection failure"
      throw err

    console.log "Initializing database..."
    db = nano.db.use name

    # Convenience function to create sorting list design documents
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

    ### Design Documents ###

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
        by_token:
          map: (doc) ->
            return unless doc.type is "user"
            for token in doc.tokens
              emit token, doc

    counter = 4
    finalize = (err) ->
      throw err if err?
      if --counter is 0
        callback?()

    overwrite_item db, "_design/bookmarks", design_bookmarks, finalize
    overwrite_item db, "_design/lists", design_lists, finalize
    overwrite_item db, "_design/users", design_users, finalize
    overwrite_item db, "_design/friends", design_friends, finalize

  # Helper function to overwrite an existing document
  overwrite_item = (db, id, obj, callback) ->
    db.get id, (err, old_obj) ->
      if old_obj?
        obj._rev = old_obj._rev
      db.insert obj, id, callback

module.exports = init

if require.main is module
  init()
