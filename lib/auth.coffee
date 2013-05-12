crypto = require "crypto"

check = (req, res, next) ->
  return res.redirect "/login" unless req.session.user?
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
