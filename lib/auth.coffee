crypto = require "crypto"
users  = require "./model/user"

check = (req, res, next) ->
  # Valid session
  return next() if req.session.user

  # Try to authenticate by token
  token = req.param "token"
  return res.redirect "/login" unless token

  users.get_by_token token, (err, user) ->
    return res.send 403 if err? or not user?

    # Valid token
    req.session.user = user._id
    next()

calculate_hash = (pass, salt) ->
  shasum = crypto.createHash "sha1"
  shasum.update pass + salt
  shasum.digest "hex"

authenticate = (user, pass) ->
  hash = calculate_hash pass, user.salt
  if hash is user.password
    user
  else
    null

exports.check = check
exports.calculate_hash = calculate_hash
exports.authenticate = authenticate
