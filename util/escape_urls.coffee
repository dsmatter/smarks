db        = require("../lib/couchdb")()
bookmarks = require "../lib/model/bookmark"
async     = require "async"

init = ->
  db.view "bookmarks", "by_list", (err, body) ->
    handle_bookmark = (bookmark, callback) ->
      bookmarks.validate bookmark, (err, bookmark) ->
        throw err if err?
        db.insert bookmark, (err) ->
          throw err if err?
          console.log "Inserted #{bookmark.url}"
          callback()

    tasks = []
    body.rows.forEach (row) ->
      tasks.push (c) -> handle_bookmark row.value, c

    async.parallel tasks, ->
      console.log "finished"

exports.init = init

if require.main is module
  init()
