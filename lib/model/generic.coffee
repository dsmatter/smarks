couchdb = require "../couchdb"
onerr   = require "../errorhandler"

get = (validate) ->
  (id, callback) ->
    couchdb.connect onerr callback, (db) ->
      db.get id, onerr callback, (doc) ->
        validate doc, callback

insert = (validate) ->
  (doc, callback) ->
    validate doc, onerr callback, ->
      couchdb.connect onerr callback, (db) ->
        db.insert doc, onerr callback, (body) ->
          doc._id = body.id
          doc._rev = body.rev
          callback null, doc

update = (validate, get, insert) ->
  (id, changes, callback) ->
    get id, onerr callback, (doc) ->
      for key of changes
        doc[key] = changes[key]
      insert doc, callback

destroy = ->
  (doc, callback) ->
    couchdb.connect onerr callback, (db) ->
      db.destroy doc._id, doc._rev, callback

infect = (exports, validate) ->
  exports.get = get validate
  exports.insert = insert validate
  exports.update = update validate, exports.get, exports.insert
  exports.destroy = destroy()

exports.infect = infect
exports.get = get
exports.insert = insert
exports.update = update
exports.destroy = destroy
