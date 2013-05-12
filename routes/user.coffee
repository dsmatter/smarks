couchdb = require "../lib/couchdb"
auth    = require "../lib/auth"
onerr   = require "../lib/errorhandler"

get = (req, res, next) ->
  couchdb.connect onerr next, (db) ->
    db.get req.session.user, onerr next, (user) ->
      res.render "user", user: user

post = (req, res, next) ->
  username     = req.param "username"
  pass         = req.param "passphrase"
  pass_confirm = req.param "passphrase_confirmation"
  email        = req.param "email"

  if username?
    couchdb.connect onerr next, (db) ->
      db.get req.session.user, onerr next, (user) ->
        user.email = email
        if pass? and pass is pass_confirm
          user.password = auth.calculate_hash pass, user.salt

        db.insert user, onerr next, ->
          res.redirect "/user"

exports.get = get
exports.post = post
