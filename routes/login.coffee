db    = require("../lib/couchdb")()
onerr = require "../lib/errorhandler"
auth  = require "../lib/auth"

get = (req, res) ->
  res.render "login"

post = (req, res, next) ->
  user = req.param "user"
  pass = req.param "password"

  authenticate user, pass, (err, user) ->
    unless user?
      res.redirect "/login"
      return

    req.session.user = user.username
    res.writeHead 301,
      Location: req.session?.saved_url ? "/"
    res.end()

authenticate = (username, pass, callback) ->
  db.get username, onerr callback, (user) ->
    user = auth.authenticate user, pass
    if user?
      callback null, user
    else
      callback new Error "Auth failed"

exports.get = get
exports.post = post
