nano = require("nano")("http://localhost:5984")

cached_db = null

exports.connect = (callback) ->
  if cached_db?
    callback? null, cached_db
    return

  nano.db.create "bookmarks", (err) ->
    if err? and err.error isnt "file_exists"
      console.log "CouchDB connection failure"
      callback err

    cached_db = nano.db.use "bookmarks"
    callback? null, cached_db
