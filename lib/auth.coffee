crypto = require "crypto"

auth_routes = [
  /^\/$/
  /\/api\//
]

middleware = ->
  (req, res, next) ->
    for route in auth_routes
      # FIXME: token
      if req.path.match(route)? and not req.session.user?
        res.redirect "/login"
        return

    # Green light
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

exports.middleware = middleware
exports.calculate_hash = calculate_hash
exports.authenticate = authenticate
