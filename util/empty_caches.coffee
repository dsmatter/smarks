db = require("../lib/couchdb")()

init = (callback) ->
  db.view "cache", "by_user_page", (err, body) ->
    entries = body.rows.map (row) -> row.value
    count = entries.length

    for entry in entries
      entry.valid = false
      db.insert entry, (err) ->
        throw err if err?
        if --count == 0
          callback?()

exports.init = init

if require.main is module
  init()
