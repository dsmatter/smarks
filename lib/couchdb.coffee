nano = require("nano")("http://localhost:5984")

cached_db = null

module.exports = (db) ->
  unless cached_db?
    db ?= "bookmarks"
    cached_db = nano.use db
    patch_db_obj cached_db
  cached_db

patch_db_obj = (db) ->
  db.list = (design, list, view, options, callback) ->
    db.get "_design/#{design}/_list/#{list}/#{view}", options, callback
