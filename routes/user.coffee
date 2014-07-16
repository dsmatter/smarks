users = require "../lib/model/user"
auth  = require "../lib/auth"
onerr = require "../lib/errorhandler"
qr    = require "qr-image"
async = require "async"
_     = require "underscore"

get = (req, res, next) ->
  users.get req.session.user, onerr next, (user) ->
    async.map user.tokens, addQR, onerr next, (tokens) ->
      user.tokens = tokens
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

new_token = (req, res, next) ->
  users.generate_token req.session.user, onerr next, (user) ->
    addQR _.last(user.tokens), onerr next, (token) ->
      res.render "partial_token", token: token

delete_token = (req, res, next) ->
  users.get req.session.user, onerr next, (user) ->
    return res.send 404 unless _.contains user.tokens, req.params.id
    user.tokens = _.without user.tokens, req.params.id
    users.insert user, onerr next, ->
      res.end()

addQR = (token, callback) ->
  qrSvg = ""
  code = qr.image token, type: "svg"
  code.on "data", (data) -> qrSvg += data
  code.on "end", -> callback null, key: token, qr: qrSvg
  code.on "error", callback

exports.get = get
exports.post = post
exports.new_token = new_token
exports.delete_token = delete_token
