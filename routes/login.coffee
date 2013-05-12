couchdb = require "../lib/couchdb"
auth    = require "../lib/auth"

get = (req, res) ->
  res.render "login"

post = (req, res) ->
  user = req.param "user"
  pass = req.param "password"

  authenticate user, pass, (user) ->
    unless user?
      res.redirect "/login"
      return

    req.session.user = user.username
    res.redirect "/"

authenticate = (username, pass, callback) ->
  couchdb.connect (db) ->
    db.get username, (err, user) ->
      if err?
        callback()
        return
      callback(auth.authenticate user, pass)

exports.get = get
exports.post = post
