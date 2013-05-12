users   = require "../lib/model/user"
couchdb = require "../lib/couchdb"
auth    = require "../lib/auth"
onerr   = require "../lib/errorhandler"

get = (req, res, next) ->
  users.get req.session.user, onerr next, (user) ->
    console.log user
    res.render "user", user: user

post = (req, res, next) ->
  username     = req.param "username"
  pass         = req.param "passphrase"
  pass_confirm = req.param "passphrase_confirmation"
  email        = req.param "email"

  users.get req.session.user, onerr next, (user) ->
    user.email = email
    if pass? and pass.length > 0 and pass is pass_confirm
      user.password = auth.calculate_hash pass, user.salt

    users.insert user, onerr next, ->
      res.redirect "/"

exports.get = get
exports.post = post
