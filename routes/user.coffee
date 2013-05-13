users = require "../lib/model/user"
auth  = require "../lib/auth"
onerr = require "../lib/errorhandler"
_     = require "underscore"

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

new_token = (req, res, next) ->
  users.generate_token req.session.user, onerr next, (user) ->
    res.render "partial_token", token: _.last user.tokens

delete_token = (req, res, next) ->
  users.get req.session.user, onerr next, (user) ->
    user.tokens = _.without user.tokens, req.params.id
    users.insert user, onerr next, ->
      res.end()

exports.get = get
exports.post = post
exports.new_token = new_token
exports.delete_token = delete_token
